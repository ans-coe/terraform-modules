terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.19.1"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 2.2.0"
    }
  }
}
