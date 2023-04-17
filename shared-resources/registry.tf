resource "azurerm_container_registry" "registry" {
  name                = "${replace(var.project_name, "-", "")}registry"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
}
