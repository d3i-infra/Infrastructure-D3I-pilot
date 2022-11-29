# Todo: The application should only have write access, not read access
resource "azurerm_storage_account" "sa" {
  name                     = "${replace(lower(var.project_name), "-", "")}sa${var.project_name}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  queue_properties {
    logging {
      read                  = true
      write                 = true
      delete                = true
      retention_policy_days = 100
      version               = 1.0
    }
  }
}

resource "azurerm_storage_container" "sc" {
  name                  = "${lower(var.project_name)}-sc-${var.environment}"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

## The generated storage account credentials are stored in the key vault for human access if required
resource "azurerm_key_vault_secret" "sausername" {
  name         = "saaccountname"
  value        = azurerm_storage_account.sa.name
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "sakey" {
  name         = "sakey"
  value        = azurerm_storage_account.sa.primary_access_key
  key_vault_id = azurerm_key_vault.kv.id
}
