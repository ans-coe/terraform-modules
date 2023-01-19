locals {
  default_acl_action = var.allowed_ips == null && var.allowed_subnet_ids == null ? "Allow" : "Deny"
  msgraph_roles = toset(concat(
    ["Application.ReadWrite.OwnedBy"],
    var.msgraph_roles
  ))
}
