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
    "repositories" = var.enable_repositories ? "enabled" : "disabled"
    "boards"       = var.enable_boards ? "enabled" : "disabled"
    "pipelines"    = var.enable_pipelines ? "enabled" : "disabled"
    "testplans"    = var.enable_testplans ? "enabled" : "disabled"
    "artifacts"    = var.enable_artifacts ? "enabled" : "disabled"
  }
}

resource "azuredevops_project_pipeline_settings" "main" {
  project_id = azuredevops_project.main.id

  enforce_job_scope                    = var.pipeline_settings["enforce_job_scope"]
  enforce_job_scope_for_release        = var.pipeline_settings["enforce_job_scope_for_release"]
  enforce_referenced_repo_scoped_token = var.pipeline_settings["enforce_referenced_repo_scoped_token"]
  enforce_settable_var                 = var.pipeline_settings["enforce_settable_var"]
  publish_pipeline_metadata            = var.pipeline_settings["publish_pipeline_metadata"]
  status_badges_are_private            = var.pipeline_settings["status_badges_are_private"]
}

###############
# Repositories
###############

resource "azuredevops_git_repository" "main" {
  for_each = var.repositories

  project_id = azuredevops_project.main.id
  name       = each.value
  initialization { init_type = var.repository_initialization_type }

  # Ignore changes to initialization, ensuring imported repositories are not recreated.
  lifecycle { ignore_changes = [initialization] }
}

resource "azuredevops_team" "main" {
  for_each = var.teams

  project_id  = azuredevops_project.main.id
  name        = each.key
  description = each.value["description"]
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
  for_each = var.environments

  project_id  = azuredevops_project.main.id
  name        = each.key
  description = each.value["description"]
}

resource "azuredevops_check_approval" "main" {
  for_each = {
    for k, v in var.environments
    : k => v
    if length(v.approval.approvers) > 0
  }

  project_id           = azuredevops_project.main.id
  target_resource_id   = azuredevops_environment.main[each.key].id
  target_resource_type = "environment"

  approvers                  = each.value["approval"].approvers
  minimum_required_approvers = each.value["approval"].min_approvers
  requester_can_approve      = each.value["approval"].requester_can_approve
  timeout                    = each.value["approval"].timeout
  instructions               = each.value["approval"].instructions
}

resource "azuredevops_check_branch_control" "main" {
  for_each = {
    for k, v in var.environments
    : k => v
    if v.allowed_branches.branches != null
  }

  project_id           = azuredevops_project.main.id
  target_resource_id   = azuredevops_environment.main[each.key].id
  target_resource_type = "environment"

  display_name                     = "Allowed Branches"
  allowed_branches                 = each.value["allowed_branches"].branches
  verify_branch_protection         = each.value["allowed_branches"].verify_branch_protection
  ignore_unknown_protection_status = each.value["allowed_branches"].ignore_unknown_protection_status
}

#####################
# Repository Policies
#####################

resource "azuredevops_repository_policy_author_email_pattern" "main" {
  count = var.author_email_policy != null ? 1 : 0

  project_id = azuredevops_project.main.id
  enabled    = true
  blocking   = var.author_email_policy["blocking"]

  author_email_patterns = var.author_email_policy["email_patterns"]

  repository_ids = local.author_email_policy_repository_ids
}

resource "azuredevops_repository_policy_file_path_pattern" "main" {
  count = var.file_path_policy != null ? 1 : 0

  project_id = azuredevops_project.main.id
  enabled    = true
  blocking   = var.file_path_policy["blocking"]

  filepath_patterns = var.file_path_policy["denied_paths"]

  repository_ids = local.file_path_policy_repository_ids
}

resource "azuredevops_repository_policy_reserved_names" "main" {
  count = var.reserved_names_policy != null ? 1 : 0

  project_id = azuredevops_project.main.id
  enabled    = true
  blocking   = var.reserved_names_policy["blocking"]

  repository_ids = local.reserved_names_policy_repository_ids
}

resource "azuredevops_repository_policy_case_enforcement" "main" {
  count = var.case_enforcement_policy != null ? 1 : 0

  project_id = azuredevops_project.main.id
  enabled    = true
  blocking   = var.case_enforcement_policy["blocking"]

  enforce_consistent_case = true

  repository_ids = local.case_enforcement_policy_repository_ids
}

resource "azuredevops_repository_policy_max_path_length" "main" {
  count = var.path_length_policy != null ? 1 : 0

  project_id = azuredevops_project.main.id
  enabled    = true
  blocking   = var.path_length_policy["blocking"]

  max_path_length = var.path_length_policy["max_path_length"]

  repository_ids = local.path_length_policy_repository_ids
}

resource "azuredevops_repository_policy_max_file_size" "main" {
  count = var.file_size_policy != null ? 1 : 0

  project_id = azuredevops_project.main.id
  enabled    = true
  blocking   = var.file_size_policy["blocking"]

  max_file_size = var.file_size_policy["max_file_size"]

  repository_ids = local.file_size_policy_repository_ids
}

#################
# Branch Policies
#################

resource "azuredevops_branch_policy_min_reviewers" "main" {
  count = var.review_policy != null ? 1 : 0

  project_id = azuredevops_project.main.id

  enabled  = true
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
  count = var.work_item_policy != null ? 1 : 0

  project_id = azuredevops_project.main.id

  enabled  = true
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
  count = var.comment_policy != null ? 1 : 0

  project_id = azuredevops_project.main.id

  enabled  = true
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
