// This resource is used to share data resources to other configurations.
//
// It will be used to share: 
// * The name of the registry
// * the principal_id of the registry

resource "azurerm_automation_account" "automation-account" {
  name                = "tfex-${var.project_name}-automation-account"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Basic"
}

resource "azurerm_automation_variable_string" "registry-name" {
  name                    = "tfex-registry-name-var"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.automation-account.name
  value                   = azurerm_container_registry.registry.name
}

resource "azurerm_automation_variable_string" "registry-id" {
  name                    = "tfex-registry-id-var"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.automation-account.name
  value                   = azurerm_container_registry.registry.id
}
