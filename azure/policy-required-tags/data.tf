data "azurerm_policy_definition" "tag_resources" {
  display_name = "Require a tag on resources"
}

data "azurerm_policy_definition" "tag_resource_groups" {
  display_name = "Require a tag on resource groups"
}
