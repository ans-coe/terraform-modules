#############
# Policy Set
#############

resource "azurerm_policy_set_definition" "main" {
  name                = var.name
  display_name        = var.display_name
  description         = "A set of locations where deployment of resources and resource groups is allowed."
  policy_type         = "Custom"
  management_group_id = var.management_group_id

  parameters = jsonencode({
    allowedLocations = {
      type = "Array",
      metadata = {
        description = "The list of locations we are allowed to deploy to."
        displayName = "Allowed Locations"
        strongType  = "Location"
      }
    }
  })

  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.location_resources.id

    reference_id     = "resource_locations"
    parameter_values = jsonencode({ listOfAllowedLocations = { value = "[parameters('allowedLocations')]" } })
  }

  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.location_resource_groups.id

    reference_id     = "resource_group_locations"
    parameter_values = jsonencode({ listOfAllowedLocations = { value = "[parameters('allowedLocations')]" } })
  }
}

##############
# Assignments
##############

resource "azurerm_management_group_policy_assignment" "main" {
  for_each = local.management_group_scopes

  name         = var.name
  display_name = format("%s on '%s'", var.display_name, each.value)
  description = format(
    "Assigned to allow deployment to a specific set of locations, including: %s",
    join(", ", var.locations)
  )

  management_group_id  = each.value
  policy_definition_id = azurerm_policy_set_definition.main.id

  not_scopes = var.exclude_scopes
  enforce    = var.enforce

  parameters = jsonencode({ allowedLocations = { value = var.locations } })
}

resource "azurerm_subscription_policy_assignment" "main" {
  for_each = local.subscription_scopes

  name         = var.name
  display_name = format("%s on '%s'", var.display_name, each.value)
  description = format(
    "Assigned to allow deployment to a specific set of locations, including: %s",
    join(", ", var.locations)
  )

  subscription_id      = each.value
  policy_definition_id = azurerm_policy_set_definition.main.id

  not_scopes = var.exclude_scopes
  enforce    = var.enforce

  parameters = jsonencode({ allowedLocations = { value = var.locations } })
}

resource "azurerm_resource_group_policy_assignment" "main" {
  for_each = local.resource_group_scopes

  name         = var.name
  display_name = format("%s on '%s'", var.display_name, each.value)
  description = format(
    "Assigned to allow deployment to a specific set of locations, including: %s",
    join(", ", var.locations)
  )

  resource_group_id    = each.value
  policy_definition_id = azurerm_policy_set_definition.main.id

  enforce = var.enforce

  parameters = jsonencode({ allowedLocations = { value = var.locations } })
}
