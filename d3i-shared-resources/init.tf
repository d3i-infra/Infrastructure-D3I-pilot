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
  features {}
}

data "azurerm_subscription" "primary" {}
data "azurerm_client_config" "current" {}


##############################################################################
# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${lower(var.project_name)}-rg"
  location = var.location
  tags = {
    source      = "Terraform"
  }
}

