resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-vnet-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet" "webapp" {
  name                 = "${var.project_name}-webapp-subnet-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "web"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }
}

resource "azurerm_subnet" "database" {
  name                 = "${var.project_name}-database-subnet-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

####################################################################
# Configuration for private endpoint and link

resource "azurerm_subnet" "endpoint-subnet" {
  name                 = "${var.project_name}-endpoint-subnet-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]

  private_endpoint_network_policies_enabled = true
}

# Create Private DNS Zone
resource "azurerm_private_dns_zone" "dns-zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

# Create Private DNS Zone Network Link
resource "azurerm_private_dns_zone_virtual_network_link" "network_link" {
  name                  = "storageaccount_vnl"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns-zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# Create Private Endpint
resource "azurerm_private_endpoint" "endpoint" {
  name                = "storageaccount_pe"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.endpoint-subnet.id

  private_service_connection {
    name                           = "storageaccount_psc"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

# Create DNS A Record
resource "azurerm_private_dns_a_record" "dns_a" {
  name                = azurerm_storage_account.sa.name
  zone_name           = azurerm_private_dns_zone.dns-zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.endpoint.private_service_connection.0.private_ip_address]
}
