terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.21.0"
    }
  }

  # I created the storage account and container by hand
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "d3itfstorage"
    container_name       = "tfstateblobstore"
    key                  = "terraform.tfstate" # This is the name of the terraform state file
  }

}

# Specific to the azurerm
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {}
data "azurerm_client_config" "current" {}


##############################################################################
# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.environment}-${var.project_name}-rg"
  location = var.location
  tags = {
    environment = var.environment
    source      = "Terraform"
  }
}

##############################################################################
# Create the key_vault
# - Set access policy for the user that is loged in with az login
# - Populate key vault
resource "azurerm_key_vault" "kv" {
  name                        = "${var.project_name}-kv"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled    = false
  soft_delete_retention_days  = 7
  sku_name                    = "standard"

  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = [var.local_ip]
    virtual_network_subnet_ids = [azurerm_subnet.subnet1.id]
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

resource "azurerm_key_vault_secret" "postgrespassword" {
  name         = "postgres-password"
  value        = var.postgres_password
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "dataencryptionpublicrsakey" {
  name         = "data-encryption-public-rsa-key"
  value        = var.data_encryption_public_rsa_key
  key_vault_id = azurerm_key_vault.kv.id
}


##############################################################################
# Define the Azure web app:
# - Define the service plan
# - The web app
# - Configure access

resource "azurerm_service_plan" "sp" {
  name                = "${var.project_name}-sp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "wa" {
  name                      = "${var.project_name}-wa"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  service_plan_id           = azurerm_service_plan.sp.id
  virtual_network_subnet_id = azurerm_subnet.subnet1.id

  site_config {
    application_stack {
      docker_image     = "${azurerm_container_registry.reg.name}/my_image"
      docker_image_tag = "latest"
    }

  }

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL = "https://${azurerm_container_registry.reg.name}.azurecr.io"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Assign reader role on our storage account
# Note: the owner role is read and write, only write is nessesary, this can be configured using a custom role
resource "azurerm_role_assignment" "storage-blob-data-reader" {
  role_definition_name = "Storage Blob Data Owner"
  scope                = azurerm_storage_account.sa.id
  principal_id         = azurerm_linux_web_app.wa.identity[0].principal_id
}

# Setup key vault access policy for the web app
resource "azurerm_key_vault_access_policy" "web-app-secret-access" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_web_app.wa.identity[0].principal_id

  key_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Get",
  ]
}

# Grant pull rights from the our azure container registry
resource "azurerm_role_assignment" "arc-pull" {
  principal_id         = azurerm_linux_web_app.wa.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.reg.id
}

##############################################################################
# Create storageaccount and container

resource "azurerm_storage_account" "sa" {
  name                     = "${replace(var.project_name, "-", "")}storageaccount"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "sc" {
  name                  = "${var.project_name}-sc"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

# Network rules for storage account only allow from subnet
resource "azurerm_storage_account_network_rules" "storage-account-network-rules" {
  storage_account_id = azurerm_storage_account.sa.id

  default_action             = "Deny"
  ip_rules                   = ["127.0.0.1", var.local_ip]
  virtual_network_subnet_ids = [azurerm_subnet.subnet1.id]
  bypass                     = ["AzureServices"]
}

##############################################################################
# Create azure container registry 

resource "azurerm_container_registry" "reg" {
  name                = "${replace(var.project_name, "-", "")}registry"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
}

##############################################################################
# Create PostgreSQL database on Azure 
# Note: I am not quite sure how this should be configured
# I think this should be workable

resource "azurerm_private_dns_zone" "dns" {
  name                = "${var.project_name}.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "virtual-network-link" {
  name                  = "${var.project_name}-virtual-network-link"
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
}

resource "azurerm_postgresql_flexible_server" "example" {
  name                   = "${var.project_name}-psqlflexibleserver"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "12"
  delegated_subnet_id    = azurerm_subnet.subnet2.id
  private_dns_zone_id    = azurerm_private_dns_zone.dns.id
  administrator_login    = var.postgres_username
  administrator_password = var.postgres_password
  zone                   = "1" # This is the availability zone

  storage_mb = 32768 # I believe this is the least amount possible

  sku_name   = "B_Standard_B2s"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.virtual-network-link]

}


##############################################################################
# Create azure virtual network and subnet

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet" "subnet1" {
  name                 = "${var.project_name}-subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Web"]

  delegation {
    name = "serverfarmdelegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_subnet" "subnet2" {
  name                 = "${var.project_name}-subnet2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "flexibleservers"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }

}

##############################################################################
# Setup cost monitoring

resource "azurerm_monitor_action_group" "monitor-action-group" {
  name                = "${var.project_name}-monitor-action-group"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "mon-act-grp"
}

resource "azurerm_consumption_budget_resource_group" "budget-rg" {
  name              = "${var.project_name}-budget-rg"
  resource_group_id = azurerm_resource_group.rg.id

  amount     = 200
  time_grain = "Monthly"

  time_period {
    start_date = "2022-09-01T00:00:00Z"
    end_date   = "2023-09-01T00:00:00Z"
  }

  filter {
    dimension {
      name = "ResourceId"
      values = [
        azurerm_monitor_action_group.monitor-action-group.id,
      ]
    }

    tag {
      name = "environment"
      values = [
        var.environment,
      ]
    }
  }

  notification {
    enabled        = true
    threshold      = 90.0
    operator       = "EqualTo"
    threshold_type = "Forecasted"

    contact_emails = [
      var.owner_email,
    ]

    contact_groups = [
      azurerm_monitor_action_group.monitor-action-group.id,
    ]

    contact_roles = [
      "Owner",
    ]
  }

  notification {
    enabled   = false
    threshold = 100.0
    operator  = "GreaterThan"

    contact_emails = [
      var.owner_email
    ]
  }
}
