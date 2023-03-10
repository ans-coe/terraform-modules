###########
# Policies
###########

data "azurerm_policy_definition" "tag_resources" {
  display_name = "Require a tag on resources"
}

data "azurerm_policy_definition" "tag_resource_groups" {
  display_name = "Require a tag on resource groups"
}

#############
# Policy Set
#############

resource "azurerm_policy_set_definition" "required_tags" {
  name         = "cus_reqtags"
  display_name = "Require Tags"
  description = format(
    "A set of tags that need to be present on resources and resource groups targetted by this policy. These include: %s",
    join(", ", var.tags)
  )
  policy_type         = "Custom"
  management_group_id = var.management_group_id

  dynamic "policy_definition_group" {
    for_each = var.tags
    iterator = tag

    content {
      name        = format("%s_tag", tag.value)
      category    = "Tagging"
      description = format("Requires the '%s' tag.", tag.value)
    }
  }

  dynamic "policy_definition_reference" {
    for_each = var.tags
    iterator = tag

    content {
      policy_definition_id = data.azurerm_policy_definition.tag_resources.id
      policy_group_names   = [format("%s_tag", tag.value)]

      reference_id     = format("%s_resource_tag", tag.value)
      parameter_values = jsonencode({ tagName = { value = tag.value } })
    }
  }

  dynamic "policy_definition_reference" {
    for_each = var.tags
    iterator = tag

    content {
      policy_definition_id = data.azurerm_policy_definition.tag_resource_groups.id
      policy_group_names   = [format("%s_tag", tag.value)]

      reference_id     = format("%s_resource_group_tag", tag.value)
      parameter_values = jsonencode({ tagName = { value = tag.value } })
    }
  }
}

##############
# Assignments
##############

resource "azurerm_management_group_policy_assignment" "required_tags" {
  for_each = toset(length(var.tags) == 0 ? [] : local.management_group_scopes)

  name = format("%s-m", azurerm_policy_set_definition.required_tags.name)
  display_name = format(
    "%s on '%s'",
    azurerm_policy_set_definition.required_tags.display_name, each.value
  )
  description = format(
    "Assigned to force resource groups and resources to require a set of tags. These include: %s",
    join(", ", var.tags)
  )

  management_group_id  = each.value
  policy_definition_id = azurerm_policy_set_definition.required_tags.id

  not_scopes = var.exclude_scopes
  enforce    = var.enforce
}

resource "azurerm_subscription_policy_assignment" "required_tags" {
  for_each = toset(length(var.tags) == 0 ? [] : local.subscription_scopes)

  name = format("%s-s", azurerm_policy_set_definition.required_tags.name)
  display_name = format(
    "%s on '%s'",
    azurerm_policy_set_definition.required_tags.display_name, each.value
  )
  description = format(
    "Assigned to force resource groups and resources to require a set of tags. These include: %s",
    join(", ", var.tags)
  )

  subscription_id      = each.value
  policy_definition_id = azurerm_policy_set_definition.required_tags.id

  not_scopes = var.exclude_scopes
  enforce    = var.enforce
}

resource "azurerm_resource_group_policy_assignment" "required_tags" {
  for_each = toset(length(var.tags) == 0 ? [] : local.resource_group_scopes)

  name = format("%s-r", azurerm_policy_set_definition.required_tags.name)
  display_name = format(
    "%s on '%s'",
    azurerm_policy_set_definition.required_tags.display_name, each.value
  )
  description = format(
    "Assigned to force resource groups and resources to require a set of tags. These include: %s",
    join(", ", var.tags)
  )

  resource_group_id    = each.value
  policy_definition_id = azurerm_policy_set_definition.required_tags.id

  enforce = var.enforce
}
