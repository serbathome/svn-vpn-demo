output "private_endpoint_id" {
  value = azurerm_private_endpoint.svn.id
}

output "private_endpoint_ip" {
  value = azurerm_private_endpoint.svn.private_service_connection[0].private_ip_address
}
