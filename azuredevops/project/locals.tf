locals {
  # Team Configuration

  team_administrators = {
    for team, props in var.teams
    : team => props.administrators
    if props.administrators != null
  }

  team_members = {
    for team, props in var.teams
    : team => props.members
    if props.members != null
  }

  # Repository policies

  author_email_policy_repository_ids = var.author_email_policy != null ? [
    for r in var.author_email_policy["repositories"]
    : azuredevops_git_repository.main[r].id
  ] : []

  file_path_policy_repository_ids = var.file_path_policy != null ? [
    for r in var.file_path_policy["repositories"]
    : azuredevops_git_repository.main[r].id
  ] : []

  reserved_names_policy_repository_ids = var.reserved_names_policy != null ? [
    for r in var.reserved_names_policy["repositories"]
    : azuredevops_git_repository.main[r].id
  ] : []

  case_enforcement_policy_repository_ids = var.case_enforcement_policy != null ? [
    for r in var.case_enforcement_policy["repositories"]
    : azuredevops_git_repository.main[r].id
  ] : []

  path_length_policy_repository_ids = var.path_length_policy != null ? [
    for r in var.path_length_policy["repositories"]
    : azuredevops_git_repository.main[r].id
  ] : []

  file_size_policy_repository_ids = var.file_size_policy != null ? [
    for r in var.file_size_policy["repositories"]
    : azuredevops_git_repository.main[r].id
  ] : []

  review_policy_repository_ids = var.review_policy != null ? [
    for r in var.review_policy["repositories"]
    : azuredevops_git_repository.main[r].id
  ] : []
  review_policy_scopes = coalescelist(local.review_policy_repository_ids, [null])

  work_item_policy_repository_ids = var.work_item_policy != null ? [
    for r in var.work_item_policy["repositories"]
    : azuredevops_git_repository.main[r].id
  ] : []
  work_item_policy_scopes = coalescelist(local.work_item_policy_repository_ids, [null])

  comment_policy_repository_ids = var.comment_policy != null ? [
    for r in var.comment_policy["repositories"]
    : azuredevops_git_repository.main[r].id
  ] : []
  comment_policy_scopes = coalescelist(local.comment_policy_repository_ids, [null])
}
