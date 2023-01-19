locals {
  # Team Configuration

  team_administrators = {
    for team in toset(var.teams)
    : team.name => team.administrators
    if team.administrators != null
  }

  team_members = {
    for team in toset(var.teams)
    : team.name => team.members
    if team.members != null
  }

  # Environments

  environments = {
    for env in toset(var.environments)
    : env.name => env
  }

  # Repository policies

  author_email_policy_repository_ids = concat(
    [
      for r in var.author_email_policy["repository_names"]
      : azuredevops_git_repository.main[r].id
    ],
    var.author_email_policy["repository_ids"]
  )

  file_path_policy_repository_ids = concat(
    [
      for r in var.file_path_policy["repository_names"]
      : azuredevops_git_repository.main[r].id
    ],
    var.file_path_policy["repository_ids"]
  )

  reserved_names_policy_repository_ids = concat(
    [
      for r in var.reserved_names_policy["repository_names"]
      : azuredevops_git_repository.main[r].id
    ],
    var.reserved_names_policy["repository_ids"]
  )

  case_enforcement_policy_repository_ids = concat(
    [
      for r in var.case_enforcement_policy["repository_names"]
      : azuredevops_git_repository.main[r].id
    ],
    var.case_enforcement_policy["repository_ids"]
  )

  path_length_policy_repository_ids = concat(
    [
      for r in var.path_length_policy["repository_names"]
      : azuredevops_git_repository.main[r].id
    ],
    var.path_length_policy["repository_ids"]
  )

  file_size_policy_repository_ids = concat(
    [
      for r in var.file_size_policy["repository_names"]
      : azuredevops_git_repository.main[r].id
    ],
    var.file_size_policy["repository_ids"]
  )

  review_policy_repository_ids = concat(
    [
      for r in var.review_policy["repository_names"]
      : azuredevops_git_repository.main[r].id
    ],
    var.review_policy["repository_ids"]
  )
  review_policy_scopes = coalescelist(local.review_policy_repository_ids, [null])

  work_item_policy_repository_ids = concat(
    [
      for r in var.work_item_policy["repository_names"]
      : azuredevops_git_repository.main[r].id
    ],
    var.work_item_policy["repository_ids"]
  )
  work_item_policy_scopes = coalescelist(local.work_item_policy_repository_ids, [null])

  comment_policy_repository_ids = concat(
    [
      for r in var.comment_policy["repository_names"]
      : azuredevops_git_repository.main[r].id
    ],
    var.comment_policy["repository_ids"]
  )
  comment_policy_scopes = coalescelist(local.comment_policy_repository_ids, [null])
}
