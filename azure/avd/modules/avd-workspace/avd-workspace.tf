resource "azurerm_virtual_desktop_workspace" "workspace" {
  name     = var.avd_workspace_name
  location = var.location

  resource_group_name = var.resource_group_name

  friendly_name = var.workspace_config.friendly_name
  description   = var.workspace_config.description

  public_network_access_enabled = var.workspace_config.public_network_access_enabled

  tags = merge(local.default_tags, var.extra_tags)
}
