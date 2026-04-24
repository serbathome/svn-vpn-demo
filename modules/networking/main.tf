# ── DMZ VNet ────────────────────────────────────────────────

resource "azurerm_virtual_network" "dmz" {
  name                = "vnet-dmz"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.dmz_vnet_address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "gateway" {
  name                           = "GatewaySubnet"
  resource_group_name            = var.resource_group_name
  virtual_network_name           = azurerm_virtual_network.dmz.name
  address_prefixes               = [var.gateway_subnet_prefix]
  default_outbound_access_enabled = false
}

resource "azurerm_subnet" "appgw" {
  name                           = "snet-appgw"
  resource_group_name            = var.resource_group_name
  virtual_network_name           = azurerm_virtual_network.dmz.name
  address_prefixes               = [var.appgw_subnet_prefix]
  default_outbound_access_enabled = false
}

resource "azurerm_subnet" "pe" {
  name                              = "snet-pe"
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.dmz.name
  address_prefixes                  = [var.pe_subnet_prefix]
  private_endpoint_network_policies = "Disabled"
  default_outbound_access_enabled   = false
}

# ── BMW VNet ────────────────────────────────────────────────

resource "azurerm_virtual_network" "bmw" {
  name                = "vnet-bmw"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.bmw_vnet_address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "pls" {
  name                                          = "snet-pls"
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.bmw.name
  address_prefixes                              = [var.pls_subnet_prefix]
  private_link_service_network_policies_enabled = false
  default_outbound_access_enabled               = false
}

resource "azurerm_subnet" "svn" {
  name                           = "snet-svn"
  resource_group_name            = var.resource_group_name
  virtual_network_name           = azurerm_virtual_network.bmw.name
  address_prefixes               = [var.svn_subnet_prefix]
  default_outbound_access_enabled = false
}

# ── NSGs ────────────────────────────────────────────────────

resource "azurerm_network_security_group" "appgw" {
  name                = "nsg-appgw"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "AllowGatewayManager"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.svn_port)
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "svn" {
  name                = "nsg-svn"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "AllowLBProbe"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.svn_port)
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSVNFromPLS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.svn_port)
    source_address_prefix      = var.pls_subnet_prefix
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "appgw" {
  subnet_id                 = azurerm_subnet.appgw.id
  network_security_group_id = azurerm_network_security_group.appgw.id
}

resource "azurerm_subnet_network_security_group_association" "svn" {
  subnet_id                 = azurerm_subnet.svn.id
  network_security_group_id = azurerm_network_security_group.svn.id
}
