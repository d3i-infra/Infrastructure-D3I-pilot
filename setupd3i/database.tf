#############################################################################
# Create PostgreSQL database on Azure 
# Note: I am not quite sure how this should be configured
# I think this should be workable

resource "azurerm_private_dns_zone" "dns" {
  name                = "${var.project_name}.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "virtual-network-link-database" {
  name                  = "${lower(var.project_name)}-virtual-network-link"
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
}

resource "azurerm_postgresql_flexible_server" "database" {
  name                   = "${lower(var.project_name)}-psql-database"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "12"
  delegated_subnet_id    = azurerm_subnet.database.id
  private_dns_zone_id    = azurerm_private_dns_zone.dns.id
  administrator_login    = var.postgres_username
  administrator_password = azurerm_key_vault_secret.postgrespassword.value
  zone                   = "1" # This is the availability zone

  storage_mb = 32768 # I believe this is the least amount possible

  sku_name   = "B_Standard_B2s" # cheapest SKU mostly intended for dev/test light prod.
  #sku_name    = "GP_Standard_D2s_v3" # cheapest 'normal production worthy' SKU I could find

  depends_on = [azurerm_private_dns_zone_virtual_network_link.virtual-network-link-database]

}

resource "azurerm_postgresql_flexible_server_database" "postgresql-db" {
  name                = var.database_name
  server_id           = azurerm_postgresql_flexible_server.database.id
  charset             = "utf8"
  collation           = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_configuration" "azureextention" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.database.id
  value     = "CITEXT"
}

### For now the DB connection is not encrypted, needs to be worked on
### DB not used for personal info and within MS datacenter
resource "azurerm_postgresql_flexible_server_configuration" "nosecurity" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.database.id
  value     = "OFF"
}
