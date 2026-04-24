# ── Resource Group ──────────────────────────────────────────

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ── Phase 1: Networking ────────────────────────────────────

module "networking" {
  source = "./modules/networking"

  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  tags                   = var.tags
  dmz_vnet_address_space = var.dmz_vnet_address_space
  bmw_vnet_address_space = var.bmw_vnet_address_space
  gateway_subnet_prefix  = var.gateway_subnet_prefix
  appgw_subnet_prefix    = var.appgw_subnet_prefix
  pe_subnet_prefix       = var.pe_subnet_prefix
  pls_subnet_prefix      = var.pls_subnet_prefix
  svn_subnet_prefix      = var.svn_subnet_prefix
  svn_port               = var.svn_port
}

# ── Phase 2: VPN Gateway ──────────────────────────────────

module "vpn_gateway" {
  source = "./modules/vpn-gateway"

  resource_group_name     = azurerm_resource_group.this.name
  location                = azurerm_resource_group.this.location
  tags                    = var.tags
  gateway_subnet_id       = module.networking.gateway_subnet_id
  vpn_client_address_pool = var.vpn_client_address_pool
  aad_tenant_id           = var.aad_tenant_id
  aad_audience            = var.aad_audience
}

# ── Phase 3: SVN Server + LB + Private Link Service ───────

module "svn_server" {
  source = "./modules/svn-server"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = var.tags
  subscription_id     = var.subscription_id
  svn_subnet_id       = module.networking.svn_subnet_id
  pls_subnet_id       = module.networking.pls_subnet_id
  vm_admin_username   = var.vm_admin_username
  vm_admin_password   = var.vm_admin_password
  vm_size             = var.vm_size
  svn_port            = var.svn_port
}

# ── Phase 4: Private Endpoint (depends on PLS) ────────────

module "private_endpoint" {
  source = "./modules/private-endpoint"

  resource_group_name     = azurerm_resource_group.this.name
  location                = azurerm_resource_group.this.location
  tags                    = var.tags
  pe_subnet_id            = module.networking.pe_subnet_id
  private_link_service_id = module.svn_server.private_link_service_id
}

# ── Phase 5: Application Gateway + WAF ────────────────────

module "app_gateway" {
  source = "./modules/app-gateway"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = var.tags
  appgw_subnet_id     = module.networking.appgw_subnet_id
  svn_port            = var.svn_port
  private_endpoint_ip = module.private_endpoint.private_endpoint_ip
  appgw_private_ip    = cidrhost(var.appgw_subnet_prefix, 10)
}
