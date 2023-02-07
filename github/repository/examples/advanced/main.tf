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

  name               = "terraform-module-example-advanced-repository"
  description        = "An example Github repository created through a Terraform module."
  visibility         = "private"
  auto_init          = true
  archive_on_destroy = false

  topics             = ["example"]
  gitignore_template = "Terraform"
  license_template   = "mit"

  has_issues   = true
  has_projects = true
  has_wiki     = true

  deploy_keys = [{
    name       = "example"
    public_key = file("${path.module}/files/example.pub")
  }]

  webhooks = [{
    url          = "https://www.example.com"
    content_type = "json"
    events       = ["push"]
  }]

  issue_labels = [{
    name        = "example"
    description = "Example issue label."
  }]
}

resource "github_repository_file" "example" {
  # Creating a file requires the repository to be created and initialised.
  # If the file exists, overwrite_on_create needs to be true.
  repository = module.repository.name
  file       = "example.md"

  content             = "Hello (advanced)."
  overwrite_on_create = true

  commit_message = "Example commit to an example repository."
}
