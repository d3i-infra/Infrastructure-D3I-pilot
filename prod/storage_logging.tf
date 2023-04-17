resource "azurerm_storage_account" "salogging" {
  name                     = "${replace(lower(var.project_name), "-", "")}sa${var.environment}logging"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_diagnostic_setting" "core-diagnostic" {
  name               = "loggingsa"
  target_resource_id = "${azurerm_storage_account.sa.id}/blobServices/default/"
  storage_account_id = azurerm_storage_account.salogging.id

  log {
    category = "StorageRead"
    enabled  = true
  }

  log {
    category = "StorageWrite"
    enabled  = true
  }

  log {
    category = "StorageDelete"
    enabled  = true
  }
}
