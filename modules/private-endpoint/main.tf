resource "azurerm_private_endpoint" "svn" {
  name                = "pep-svn"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-svn"
    private_connection_resource_id = var.private_link_service_id
    is_manual_connection           = false
  }
}
