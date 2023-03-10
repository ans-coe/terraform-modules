provider "azurerm" {
  features {}

  # Best to set your tenant_id and subscription_id
  # in code under here for safety.

  # tenant_id       = ""
  # subscription_id = ""

  storage_use_azuread = true
}

locals {
  location = "uksouth"
  tags = {
    module  = "terraform-ops"
    example = "basic"
    usage   = "demo"
  }
}

data "http" "my_ip" {
  url = "https://api.ipify.org"

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Status code from ${self.url} should return 200."
    }
  }
}

data "azurerm_subscription" "current" {}

module "terraform_ops" {
  source = "../../"

  location = local.location
  tags     = local.tags

  managed_scopes = [data.azurerm_subscription.current.id]
  allowed_ips    = [data.http.my_ip.response_body]

  application_name         = "Terraform Example"
  group_name               = "Terraform Example Operators"
  storage_account_name     = "tfmexbasictfotfsa"
  enable_shared_access_key = false
  key_vault_name           = "tfmexbasictfokv"
}
