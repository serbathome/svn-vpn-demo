locals {
  backend_pool_name      = "bep-svn"
  http_setting_name      = "http-setting-svn"
  frontend_ip_public     = "fe-pip-agw"
  frontend_ip_private    = "fe-private-agw"
  frontend_port_name     = "fp-https"
  frontend_port_http_name = "port_80"
  listener_name          = "lst-https"
  listener_http_name     = "lst-http"
  request_routing_name   = "rule-svn"
  probe_name             = "probe-svn"
}

resource "azurerm_public_ip" "agw" {
  name                = "pip-agw"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags

  ip_tags = {
    "FirstPartyUsage" = "/Unprivileged"
  }
}

# ── WAF Policy ──────────────────────────────────────────────

resource "azurerm_web_application_firewall_policy" "this" {
  name                = "waf-policy-svn"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  policy_settings {
    enabled                     = true
    mode                        = "Detection"
    request_body_check          = true
    max_request_body_size_in_kb = 128
    file_upload_limit_in_mb     = 100
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}

# ── Application Gateway (WAF_v2) ───────────────────────────

resource "azurerm_application_gateway" "this" {
  name                = "agw-dmz"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  firewall_policy_id  = azurerm_web_application_firewall_policy.this.id

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "gateway-ipconfig"
    subnet_id = var.appgw_subnet_id
  }

  # Public frontend IP — required by WAF_v2 SKU, no listener attached
  frontend_ip_configuration {
    name                 = local.frontend_ip_public
    public_ip_address_id = azurerm_public_ip.agw.id
  }

  # Private frontend IP — VPN clients connect here
  frontend_ip_configuration {
    name                          = local.frontend_ip_private
    subnet_id                     = var.appgw_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.appgw_private_ip
  }

  frontend_port {
    name = local.frontend_port_name
    port = 443
  }

  frontend_port {
    name = local.frontend_port_http_name
    port = 80
  }

  # Backend pool points to the Private Endpoint IP
  backend_address_pool {
    name         = local.backend_pool_name
    ip_addresses = [var.private_endpoint_ip]
  }

  backend_http_settings {
    name                                = local.http_setting_name
    cookie_based_affinity               = "Disabled"
    port                                = var.svn_port
    protocol                            = "Http"
    request_timeout                     = 60
    probe_name                          = local.probe_name
    host_name                           = "vm-svn"
  }

  trusted_root_certificate {
    name = "backend-root-cert"
    data = filebase64("${path.module}/backend-root.cer")
  }

  probe {
    name                = local.probe_name
    host                = "vm-svn"
    path                = "/"
    protocol            = "Http"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3

    match {
      status_code = ["200-401"]
    }
  }

  # Self-signed cert for demo — use ssl_certificate with Key Vault for production
  ssl_certificate {
    name     = "agw-ssl-cert"
    data     = filebase64("${path.module}/dummy-cert.pfx")
    password = "demo123"
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_private
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Https"
    ssl_certificate_name           = "agw-ssl-cert"
  }

  http_listener {
    name                           = local.listener_http_name
    frontend_ip_configuration_name = local.frontend_ip_private
    frontend_port_name             = local.frontend_port_http_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_name
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = local.listener_http_name
    backend_address_pool_name  = local.backend_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
