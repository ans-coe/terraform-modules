##########
# Project
##########

resource "azuredevops_project" "main" {
  name               = var.name
  description        = var.description
  visibility         = var.visibility
  version_control    = var.version_control
  work_item_template = var.work_item_template

  features = {
    "repositories" = "enabled"
    "boards"       = var.enable_boards ? "enabled" : "disabled"
    "pipelines"    = var.enable_pipelines ? "enabled" : "disabled"
    "testplans"    = var.enable_testplans ? "enabled" : "disabled"
    "artifacts"    = var.enable_artifacts ? "enabled" : "disabled"
  }
}

###############
# Repositories
###############

resource "azuredevops_git_repository" "main" {
  for_each = var.repository_names

  project_id = azuredevops_project.main.id
  name       = each.value
  initialization {
    init_type = var.repository_initialization_type
  }

  lifecycle {
    # Ignore changes to initialization, ensuring imported repositories are not recreated.
    ignore_changes = [initialization, ]
  }
}

resource "azuredevops_team" "main" {
  for_each = { for s in var.teams : s.name => s }

  project_id  = azuredevops_project.main.id
  name        = each.value.name
  description = each.value.description
}

resource "azuredevops_team_administrators" "main" {
  for_each = local.team_administrators

  project_id = azuredevops_project.main.id
  team_id    = azuredevops_team.main[each.key].id
  mode       = var.teams_membership_mode

  administrators = each.value
}

resource "azuredevops_team_members" "main" {
  for_each = local.team_members

  project_id = azuredevops_project.main.id
  team_id    = azuredevops_team.main[each.key].id
  mode       = var.teams_membership_mode

  members = each.value
}

##############
# Environments
##############

resource "azuredevops_environment" "main" {
  for_each = local.environments

  project_id  = azuredevops_project.main.id
  name        = each.value.name
  description = each.value.description
}

#####################
# Repository Policies
#####################

resource "azuredevops_repository_policy_author_email_pattern" "main" {
  project_id = azuredevops_project.main.id
  enabled    = var.author_email_policy["enabled"]
  blocking   = var.author_email_policy["blocking"]

  author_email_patterns = var.author_email_policy["email_patterns"]

  repository_ids = local.author_email_policy_repository_ids
}

resource "azuredevops_repository_policy_file_path_pattern" "main" {
  project_id = azuredevops_project.main.id
  enabled    = var.file_path_policy["enabled"]
  blocking   = var.file_path_policy["blocking"]

  filepath_patterns = var.file_path_policy["denied_paths"]

  repository_ids = local.file_path_policy_repository_ids
}

resource "azuredevops_repository_policy_reserved_names" "main" {
  project_id = azuredevops_project.main.id
  enabled    = var.reserved_names_policy["enabled"]
  blocking   = var.reserved_names_policy["blocking"]

  repository_ids = local.reserved_names_policy_repository_ids
}

resource "azuredevops_repository_policy_case_enforcement" "main" {
  project_id = azuredevops_project.main.id
  enabled    = var.case_enforcement_policy["enabled"]
  blocking   = var.case_enforcement_policy["blocking"]

  enforce_consistent_case = var.case_enforcement_policy["enabled"]

  repository_ids = local.case_enforcement_policy_repository_ids
}

resource "azuredevops_repository_policy_max_path_length" "main" {
  project_id = azuredevops_project.main.id
  enabled    = var.path_length_policy["enabled"]
  blocking   = var.path_length_policy["blocking"]

  max_path_length = var.path_length_policy["max_path_length"]

  repository_ids = local.path_length_policy_repository_ids
}

resource "azuredevops_repository_policy_max_file_size" "main" {
  project_id = azuredevops_project.main.id
  enabled    = var.file_size_policy["enabled"]
  blocking   = var.file_size_policy["blocking"]

  max_file_size = var.file_size_policy["max_file_size"]

  repository_ids = local.file_size_policy_repository_ids
}

#################
# Branch Policies
#################

resource "azuredevops_branch_policy_min_reviewers" "main" {
  project_id = azuredevops_project.main.id

  enabled  = var.review_policy["enabled"]
  blocking = var.review_policy["blocking"]

  settings {
    reviewer_count                         = var.review_policy["reviewer_count"]
    submitter_can_vote                     = var.review_policy["submitter_can_vote"]
    last_pusher_cannot_approve             = var.review_policy["last_pusher_cannot_approve"]
    allow_completion_with_rejects_or_waits = var.review_policy["complete_with_rejects_or_waits"]
    on_push_reset_approved_votes           = var.review_policy["reset_votes_on_push"]
    on_last_iteration_require_vote         = var.review_policy["require_vote_on_last_iteration"]

    dynamic "scope" {
      for_each = local.review_policy_scopes

      content {
        repository_id  = scope.value
        repository_ref = "refs/heads/${var.default_branch}"
        match_type     = "Exact"
      }
    }
  }
}

resource "azuredevops_branch_policy_work_item_linking" "main" {
  project_id = azuredevops_project.main.id

  enabled  = var.work_item_policy["enabled"]
  blocking = var.work_item_policy["blocking"]

  settings {
    dynamic "scope" {
      for_each = local.work_item_policy_scopes

      content {
        repository_id  = scope.value
        repository_ref = "refs/heads/${var.default_branch}"
        match_type     = "Exact"
      }
    }
  }
}

resource "azuredevops_branch_policy_comment_resolution" "main" {
  project_id = azuredevops_project.main.id

  enabled  = var.comment_policy["enabled"]
  blocking = var.comment_policy["blocking"]

  settings {
    dynamic "scope" {
      for_each = local.comment_policy_scopes

      content {
        repository_id  = scope.value
        repository_ref = "refs/heads/${var.default_branch}"
        match_type     = "Exact"
      }
    }
  }
}
