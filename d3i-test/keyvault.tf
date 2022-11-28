resource "azurerm_key_vault" "kv" {
  name                        = "${lower(var.project_name)}-kv-${var.environment}"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled    = false
  soft_delete_retention_days  = 7
  sku_name                    = "standard"

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = var.local_ip
  }

  # Setup keyvault access policy for the user that autheniticated
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy",
    ]
    secret_permissions = [
      "Get", "List", "Delete", "Recover", "Backup", "Restore", "Set", "Purge",
    ]

  }
}

resource "azurerm_key_vault_secret" "postgresusername" {
  name         = "postgres-username"
  value        = var.postgres_username
  key_vault_id = azurerm_key_vault.kv.id
}

resource "random_password" "database_password" {
  length  = 20
  special = false
}

resource "azurerm_key_vault_secret" "postgrespassword" {
  name         = "postgres-password"
  value        = random_password.database_password.result
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "dataencryptionpublicrsakey" {
  name         = "data-encryption-public-rsa-key"
  value        = var.data_encryption_public_rsa_key
  key_vault_id = azurerm_key_vault.kv.id
}
