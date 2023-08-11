output "policy" {
  description = "The ID of the Azure Firewall Policy"
  
  value = {
    for p in azurerm_firewall_policy.main
    : p.name => {
      id = p.id
      resource_group_name = p.resource_group_name
      sku = p.sku
      threat_intelligence_mode = p.threat_intelligence_mode
    }
  }
}

# output "child_policies" {
#   description = "Subnet configuration."
#   value = {
#     for p in azurerm_firewall_policy.main
#     : p.name => p.child_policies 
#   }
# }
