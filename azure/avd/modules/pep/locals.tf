locals {
  resource_alias = var.target_resource == 1 ? var.target_resource : null
  resource_id    = var.target_resource != 1 ? var.target_resource : null

  is_not_private_link_service = local.resource_alias == null && !contains(try(split("/", local.resource_id), []), "privateLinkServices")
}
