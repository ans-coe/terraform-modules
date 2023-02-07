output "allowed_locations_id" {
  description = "ID of the allowed locations policy set definition."
  value       = azurerm_policy_set_definition.allowed_locations.id
}

output "required_tags_id" {
  description = "ID of the required tags policy set definition."
  value       = azurerm_policy_set_definition.required_tags.id
}
