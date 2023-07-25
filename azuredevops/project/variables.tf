##################
# Project Details
##################

variable "name" {
  description = "The name of the project."
  type        = string
}

variable "description" {
  description = "The description of the project."
  type        = string
  default     = null
}

variable "visibility" {
  description = "The visibility of the project, 'private' or 'public'."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["private", "public"], var.visibility)
    error_message = "The visibility must be set to 'private' or 'public'."
  }
}

variable "pipeline_settings" {
  description = "Pipeline settings for the project."
  type = object({
    enforce_job_scope                    = optional(bool)
    enforce_job_scope_for_release        = optional(bool)
    enforce_referenced_repo_scoped_token = optional(bool)
    enforce_settable_var                 = optional(bool)
    publish_pipeline_metadata            = optional(bool)
    status_badges_are_private            = optional(bool)
  })
  default = {}
}

##################
# Version Control
##################

variable "version_control" {
  description = "The version control system to use in this project, 'Git' or 'Tfvc'."
  type        = string
  default     = "Git"

  validation {
    condition     = contains(["Git", "Tfvc"], var.version_control)
    error_message = "The version_control must be set to 'Git' or 'Tfvc'."
  }
}

variable "default_branch" {
  description = "Name of the default branch."
  type        = string
  default     = "main"
}

variable "repositories" {
  description = "Set of names to use to create new repositories under the new project."
  type        = set(string)
  default     = []
}

variable "repository_initialization_type" {
  description = "Type of initialization to use when creating repositories."
  type        = string
  default     = "Uninitialized"

  validation {
    condition     = contains(["Clean", "Uninitialized"], var.repository_initialization_type)
    error_message = "The repository_initialization_type must be set to 'Clean' or 'Uninitialized'."
  }
}

variable "teams" {
  description = "Team configuration. At least one administrator and member descriptor must be provided."
  type = map(object({
    description    = string
    administrators = optional(list(string))
    members        = optional(list(string))
  }))
  default = {}
}

variable "teams_membership_mode" {
  description = "Method used to manage memberships of teams. Add to append, Overwrite to overwrite the list. Overriden by team membership_mode setting."
  type        = string
  default     = "add"

  validation {
    condition     = contains(["add", "overwrite"], var.teams_membership_mode)
    error_message = "The teams_membership_mode must be set to 'add' or 'overwrite'."
  }
}

###################
# Project features
###################

variable "enable_repositories" {
  description = "Enable repositories."
  type        = bool
  default     = true
}

variable "enable_boards" {
  description = "Enable boards."
  type        = bool
  default     = true
}

variable "enable_pipelines" {
  description = "Enable pipelines."
  type        = bool
  default     = true
}

variable "enable_testplans" {
  description = "Enable testplans."
  type        = bool
  default     = true
}

variable "work_item_template" {
  description = "The work item template to use."
  type        = string
  default     = "Agile"

  validation {
    condition     = contains(["Agile", "Basic", "CMMI", "Scrum"], var.work_item_template)
    error_message = "The work_item_template must be set to 'Agile', 'Basic', 'CMMI', 'Scrum'."
  }
}

variable "enable_artifacts" {
  description = "Enable artifacts."
  type        = bool
  default     = true
}

##############
# Environments
##############

variable "environments" {
  description = "Environments to create in the project."
  type = map(object({
    description = optional(string, "")

    approval = optional(object({
      approvers             = optional(list(string), [])
      min_approvers         = optional(number, null)
      requester_can_approve = optional(bool, false)
      timeout               = optional(number)
      instructions          = optional(string)
    }), {})

    allowed_branches = optional(object({
      branches                         = optional(string)
      verify_branch_protection         = optional(bool)
      ignore_unknown_protection_status = optional(bool)
    }), {})
  }))
  default = {}
}

#####################
# Repository Policies
#####################

variable "author_email_policy" {
  description = "Settings for the author email policy."
  type = object({
    blocking       = optional(bool, true)
    email_patterns = optional(list(string), ["*"])
    repositories   = optional(list(string), [])
  })
  default = null
}

variable "file_path_policy" {
  description = "Settings for the file path policy."
  type = object({
    blocking     = optional(bool, true)
    denied_paths = optional(list(string), ["badpath"])
    repositories = optional(list(string), [])
  })
  default = null
}

variable "reserved_names_policy" {
  description = "Settings for the reserved names policy."
  type = object({
    blocking     = optional(bool, true)
    repositories = optional(list(string), [])
  })
  default = null
}

variable "case_enforcement_policy" {
  description = "Settings for the case enforcement policy."
  type = object({
    blocking     = optional(bool, true)
    repositories = optional(list(string), [])
  })
  default = null
}

variable "path_length_policy" {
  description = "Settings for the path length policy."
  type = object({
    blocking        = optional(bool, true)
    max_path_length = optional(number, 500)
    repositories    = optional(list(string), [])
  })
  default = null
}

variable "file_size_policy" {
  description = "Settings for the file size policy."
  type = object({
    blocking      = optional(bool, true)
    max_file_size = optional(number, 200)
    repositories  = optional(list(string), [])
  })
  default = null
}

#################
# Branch Policies
#################

variable "review_policy" {
  description = "Settings for the review policy on the default branch."
  type = object({
    blocking                       = optional(bool, true)
    reviewer_count                 = optional(number, 2)
    submitter_can_vote             = optional(bool)
    last_pusher_cannot_approve     = optional(bool)
    complete_with_rejects_or_waits = optional(bool)
    reset_votes_on_push            = optional(bool)
    require_vote_on_last_iteration = optional(bool)
    repositories                   = optional(list(string), [])
    repository_ids                 = optional(list(string), [])
  })
  default = null
}

variable "work_item_policy" {
  description = "Settings for the work item policy."
  type = object({
    blocking     = optional(bool, true)
    repositories = optional(list(string), [])
  })
  default = null
}

variable "comment_policy" {
  description = "Settings for the comment resolution policy."
  type = object({
    blocking     = optional(bool, true)
    repositories = optional(list(string), [])
  })
  default = null
}
