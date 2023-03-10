locals {
  management_group_scopes = [
    for s in var.scopes
    : s
    if startswith(s, "/providers/Microsoft.Management/managementGroups/")
  ]
  subscription_scopes = [
    for s in var.scopes
    : s
    if startswith(s, "/subscriptions/") && length(split("/", s)) == 3
  ]
  resource_group_scopes = [
    for s in var.scopes
    : s
    if startswith(s, "/subscriptions/") && length(split("/", s)) == 5
  ]
}