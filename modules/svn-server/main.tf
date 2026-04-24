# ── Network Interface ───────────────────────────────────────

resource "azurerm_network_interface" "svn" {
  name                = "nic-svn"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig-svn"
    subnet_id                     = var.svn_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# ── Windows VM ──────────────────────────────────────────────

resource "azurerm_windows_virtual_machine" "svn" {
  name                = "vm-svn"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  tags                = var.tags

  network_interface_ids = [azurerm_network_interface.svn.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}

# ── Internal Load Balancer ──────────────────────────────────

resource "azurerm_lb" "svn" {
  name                = "lbi-svn"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                          = "fe-svn"
    subnet_id                     = var.pls_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "svn" {
  name            = "bep-svn"
  loadbalancer_id = azurerm_lb.svn.id
}

resource "azurerm_network_interface_backend_address_pool_association" "svn" {
  network_interface_id    = azurerm_network_interface.svn.id
  ip_configuration_name   = "ipconfig-svn"
  backend_address_pool_id = azurerm_lb_backend_address_pool.svn.id
}

resource "azurerm_lb_probe" "svn" {
  name                = "probe-svn"
  loadbalancer_id     = azurerm_lb.svn.id
  protocol            = "Tcp"
  port                = var.svn_port
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "svn" {
  name                           = "rule-svn"
  loadbalancer_id                = azurerm_lb.svn.id
  protocol                       = "Tcp"
  frontend_port                  = var.svn_port
  backend_port                   = var.svn_port
  frontend_ip_configuration_name = "fe-svn"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.svn.id]
  probe_id                       = azurerm_lb_probe.svn.id
  floating_ip_enabled            = false
  idle_timeout_in_minutes        = 4
  disable_outbound_snat          = true
}

# ── Private Link Service ────────────────────────────────────

resource "azurerm_private_link_service" "svn" {
  name                = "pls-svn"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  load_balancer_frontend_ip_configuration_ids = [
    azurerm_lb.svn.frontend_ip_configuration[0].id
  ]

  nat_ip_configuration {
    name                       = "nat-svn"
    subnet_id                  = var.pls_subnet_id
    private_ip_address_version = "IPv4"
    primary                    = true
  }

  visibility_subscription_ids    = [var.subscription_id]
  auto_approval_subscription_ids = [var.subscription_id]
}
