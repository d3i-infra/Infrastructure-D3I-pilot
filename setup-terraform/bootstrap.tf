terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.21.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {}
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "${var.environment}-${var.resource_group}-rg"
  location = var.location
  tags = {
    environment = var.environment
    source      = "Terraform"
  }
}

resource "azurerm_storage_account" "sa" {
  name                     = "${var.environment}${var.storage_account}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_storage_container" "sc" {
  name                  = "${var.environment}${var.storage_container}"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "storage-blob-data-owner" {
  role_definition_name = "Storage Blob Data Owner"
  scope                = azurerm_storage_account.sa.id
  principal_id         = data.azurerm_client_config.current.object_id
}

