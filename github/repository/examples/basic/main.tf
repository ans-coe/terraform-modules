terraform {
  # Required per-provider as this module is not under hashicorp/*
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

module "repository" {
  source = "../../"

  name               = "terraform-module-example-basic-repository"
  description        = "An example Github repository created through a Terraform module."
  visibility         = "private"
  archive_on_destroy = false
}

resource "github_repository_file" "example" {
  # Creating a file requires the repository to be created and initialised.
  # If the file exists, overwrite_on_create needs to be true.
  repository = module.repository.name
  file       = "example.md"

  content             = "Hello."
  overwrite_on_create = true

  commit_message = "Example commit to an example repository."
}
