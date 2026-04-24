resource "azurerm_public_ip" "vpng" {
  name                = "pip-vpng"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "this" {
  name                = "vpng-dmz"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "VpnGw1AZ"

  ip_configuration {
    name                          = "vpng-ipconfig"
    public_ip_address_id          = azurerm_public_ip.vpng.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }

  vpn_client_configuration {
    address_space        = [var.vpn_client_address_pool]
    vpn_client_protocols = ["OpenVPN"]
    vpn_auth_types       = ["AAD"]

    aad_tenant   = "https://login.microsoftonline.com/${var.aad_tenant_id}/"
    aad_audience = var.aad_audience
    aad_issuer   = "https://sts.windows.net/${var.aad_tenant_id}/"
  }
}
