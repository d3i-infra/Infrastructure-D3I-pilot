resource "azurerm_storage_account" "sa" {
  name                     = "${replace(lower(var.project_name), "-", "")}sa${var.environment}"
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


data "azurerm_storage_account_blob_container_sas" "sastoken" {
  connection_string = azurerm_storage_account.sa.primary_connection_string
  container_name    = azurerm_storage_container.sc.name
  https_only        = true

  start  = "2022-11-29"
  expiry = "2023-11-29"

  permissions {
    read   = false
    add    = false
    create = true
    write  = false
    delete = false
    list   = false
  }

  cache_control       = "max-age=5"
  content_disposition = "inline"
  content_encoding    = "deflate"
  content_language    = "en-US"
  content_type        = "application/json"
}

output "sas_url_query_string" {
  value     = data.azurerm_storage_account_blob_container_sas.sastoken.sas
  sensitive = true
}
