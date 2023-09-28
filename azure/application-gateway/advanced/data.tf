data "azuread_client_config" "current" {}
data "azurerm_subscription" "current" {
  lifecycle {
    postcondition {
      condition     = data.azuread_client_config.current.tenant_id == self.tenant_id
      error_message = "This module is not compatible with Azure Lighthouse. Please ensure that you are at least a guest user in the customers tenant"
    }
  }
}