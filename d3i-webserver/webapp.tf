# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "${lower(var.project_name)}-webapp-asp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "webapp-serve-privacy-support-pages" {

  name                      = "${lower(var.project_name)}-webapp-serve-privacy-support-page"
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  service_plan_id           = azurerm_service_plan.appserviceplan.id
  https_only                = true

  site_config {
    always_on = true
    container_registry_use_managed_identity = true
    application_stack {
      docker_image     = "${azurerm_container_registry.registry.name}.azurecr.io/${var.imagename_privacy_support_server}"
      docker_image_tag = var.imagetag_privacy_support_server
    }
    minimum_tls_version = "1.2"
  }

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL = "https://${azurerm_container_registry.registry.name}.azurecr.io"
  }

  logs {
    http_logs {
      file_system {
        retention_in_days = 10
        retention_in_mb   = 50
      }
    }
    application_logs {
      file_system_level = "Verbose"
    }
    detailed_error_messages = true
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "arc-pull" {
  principal_id         = azurerm_linux_web_app.webapp-serve-privacy-support-pages.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.registry.id
}
