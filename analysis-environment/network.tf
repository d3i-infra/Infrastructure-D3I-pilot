# Network configuration

resource "azurerm_virtual_network" "main" {
  name                = "${var.hostname}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Security group for network allow ssh
resource "azurerm_network_security_group" "security-group" {
  name                = "${var.hostname}-sg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface_security_group_association" "security-group-association" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.security-group.id
}


####################################################################
# Configuration for private endpoint and link for the storage account

resource "azurerm_subnet" "endpoint-subnet-sa" {
  name                 = "endpoint-subnet-sa"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]

  private_endpoint_network_policies_enabled = true
}

# Create Private DNS Zone
resource "azurerm_private_dns_zone" "dns-zone-sa" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

# Create Private DNS Zone Network Link
resource "azurerm_private_dns_zone_virtual_network_link" "network_link" {
  name                  = "network-link-sa"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns-zone-sa.name
  virtual_network_id    = azurerm_virtual_network.main.id
}

# Create Private Endpint
resource "azurerm_private_endpoint" "endpoint-sa" {
  name                = "private-endpoint-sa"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.endpoint-subnet-sa.id

  private_service_connection {
    name                           = "private-service-connection-sa"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

# Create DNS A Record
resource "azurerm_private_dns_a_record" "dns-a-record-sa" {
  name                = azurerm_storage_account.sa.name
  zone_name           = azurerm_private_dns_zone.dns-zone-sa.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.endpoint-sa.private_service_connection.0.private_ip_address]
}
