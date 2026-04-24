output "app_gateway_id" {
  value = azurerm_application_gateway.this.id
}

output "app_gateway_private_ip" {
  value = var.appgw_private_ip
}
