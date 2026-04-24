output "private_link_service_id" {
  value = azurerm_private_link_service.svn.id
}

output "lb_frontend_ip" {
  value = azurerm_lb.svn.frontend_ip_configuration[0].private_ip_address
}

output "vm_private_ip" {
  value = azurerm_network_interface.svn.private_ip_address
}
