resource "azurerm_monitor_action_group" "monitor-action-group" {
  name                = "${var.project_name}-monitor-action-group-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "mon-act-grp"
}

resource "azurerm_consumption_budget_resource_group" "budget-rg" {
  name              = "${var.project_name}-budget-rg-${var.environment}"
  resource_group_id = azurerm_resource_group.rg.id

  amount     = 200
  time_grain = "Monthly"

  time_period {
    # Auto calculating and updating these dates causes constant changes, thus hardcodinv via vars.
    start_date = var.costmonitor_startdate
    end_date   = var.costmonitor_enddate
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
