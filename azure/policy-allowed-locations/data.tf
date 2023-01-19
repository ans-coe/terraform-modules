data "azurerm_policy_definition" "location_resources" {
  display_name = "Allowed locations"
}

data "azurerm_policy_definition" "location_resource_groups" {
  display_name = "Allowed locations for resource groups"
}
