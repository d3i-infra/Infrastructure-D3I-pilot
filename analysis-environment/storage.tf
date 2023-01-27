
resource "azurerm_storage_account" "sa" {
  name                     = "${replace(lower(var.project_name), "-", "")}${replace(lower(var.hostname), "-", "")}sa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action = "Deny"
    ip_rules       = var.local_ip
  }

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



