terraform {
  # Required per-provider as this module is not under hashicorp/*
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.3.0"
    }
  }
}

module "example" {
  source = "../../"

  name        = "terraform-module-example-basic-project"
  description = "Example project created and managed through Terraform."

  repository_names = ["repo1", "repo2"]
}

output "repositories" {
  description = "Output of repositories."
  value       = module.example.repositories
  sensitive   = true # Setting to sensitive as output is large.
}
