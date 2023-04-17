terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.21.0"
    }
  }
  backend "azurerm" {
  }
}

# Specific to the azurerm
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_subscription" "primary" {}
data "azurerm_client_config" "current" {}


# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.environment}-${lower(var.project_name)}-rg"
  location = var.location
  tags = {
    environment = var.environment
    source      = "Terraform"
  }
}

