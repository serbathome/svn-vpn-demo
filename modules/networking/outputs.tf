output "dmz_vnet_id" {
  value = azurerm_virtual_network.dmz.id
}

output "bmw_vnet_id" {
  value = azurerm_virtual_network.bmw.id
}

output "gateway_subnet_id" {
  value = azurerm_subnet.gateway.id
}

output "appgw_subnet_id" {
  value = azurerm_subnet.appgw.id
}

output "pe_subnet_id" {
  value = azurerm_subnet.pe.id
}

output "pls_subnet_id" {
  value = azurerm_subnet.pls.id
}

output "svn_subnet_id" {
  value = azurerm_subnet.svn.id
}
