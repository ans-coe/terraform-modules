output "id" {
  description = "The ID of the Azure Firewall Policy."
  value       = azurerm_firewall_policy.main.id
}

output "child_policies" {
  description = "A list of reference to child Firewall Policies of this Firewall Policy."
  value       = azurerm_firewall_policy.main.child_policies
}

output "firewalls" {
  description = "A list of references to Azure Firewalls that this Firewall Policy is associated with."
  value       = azurerm_firewall_policy.main.firewalls
}

output "rule_collection_groups" {
  description = "A list of references to Firewall Policy Rule Collection Groups that belongs to this Firewall Policy."
  value       = azurerm_firewall_policy.main.rule_collection_groups
}