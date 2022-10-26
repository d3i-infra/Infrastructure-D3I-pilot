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

/*
data "azurerm_container_registry" "reg" {
  #type = "Microsoft.ContainerRegistry"
  name = var.registry_name
  resource_group_name = "dev-terraform-registry-rg"
}

# Generate a random integer to create a globally unique name
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}*/

##############################################################################
# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.environment}-${lower(var.project_name)}-rg"
  location = var.location
  tags = {
    environment = var.environment
    source      = "Terraform"
  }
}

