terraform {
  # Required per-provider as this module is not under hashicorp/*
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 4.26.1"
    }
  }
}

module "example" {
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

  deploy_keys = {
    "example" = {
      name       = "example"
      public_key = file("${path.module}/files/example.pub")
      read_only  = true
    }
  }

  webhooks = {
    "example" = {
      url          = "https://www.example.com"
      content_type = "json"
      insecure_ssl = false
      events       = ["push"]
    }
  }

  issue_labels = {
    "example" = {
      name        = "example"
      color       = "00FF00"
      description = "Example issue label."
    }
  }

  projects = {
    "avocado" = {
      name = "avocado"
      body = ""
    }
    "melon" = {
      name = "melon"
      body = "foo"
    }
  }
}

resource "github_repository_file" "example" {
  # Creating a file requires the repository to be created and initialised.
  # If the file exists, overwrite_on_create needs to be true.
  repository = module.example.name
  file       = "example.md"

  content             = "Hello (advanced)."
  overwrite_on_create = true

  commit_message = "Example commit to an example repository."
}
