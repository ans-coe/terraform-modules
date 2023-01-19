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

variable "repository_names" {
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
  description = "List of objects to configure each team. At least one administrator and member descriptor must be provided."
  type = list(object({
    name           = string
    description    = string
    administrators = optional(list(string))
    members        = optional(list(string))
  }))
  default = []
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
  description = "List of objects to configure each environment."
  type = list(object({
    name        = string
    description = optional(string, "")
  }))
  default = []
}

#####################
# Repository Policies
#####################

variable "author_email_policy" {
  description = "Settings for the author email policy."
  type = object({
    enabled          = bool
    blocking         = optional(bool, true)
    email_patterns   = optional(list(string), ["*"])
    repository_names = optional(list(string), [])
    repository_ids   = optional(list(string), [])
  })
  default = {
    enabled = false
  }
}

variable "file_path_policy" {
  description = "Settings for the file path policy."
  type = object({
    enabled          = bool
    blocking         = optional(bool, true)
    denied_paths     = optional(list(string), ["badpath"])
    repository_names = optional(list(string), [])
    repository_ids   = optional(list(string), [])
  })
  default = {
    enabled = false
  }
}

variable "reserved_names_policy" {
  description = "Settings for the reserved names policy."
  type = object({
    enabled          = bool
    blocking         = optional(bool, true)
    repository_names = optional(list(string), [])
    repository_ids   = optional(list(string), [])
  })
  default = {
    enabled = false
  }
}

variable "case_enforcement_policy" {
  description = "Settings for the case enforcement policy."
  type = object({
    enabled          = bool
    blocking         = optional(bool, true)
    repository_names = optional(list(string), [])
    repository_ids   = optional(list(string), [])
  })
  default = {
    enabled = false
  }
}

variable "path_length_policy" {
  description = "Settings for the path length policy."
  type = object({
    enabled          = bool
    blocking         = optional(bool, true)
    max_path_length  = optional(number, 500)
    repository_names = optional(list(string), [])
    repository_ids   = optional(list(string), [])
  })
  default = {
    enabled = false
  }
}

variable "file_size_policy" {
  description = "Settings for the file size policy."
  type = object({
    enabled          = bool
    blocking         = optional(bool, true)
    max_file_size    = optional(number, 200)
    repository_names = optional(list(string), [])
    repository_ids   = optional(list(string), [])
  })
  default = {
    enabled = false
  }
}

#################
# Branch Policies
#################

variable "review_policy" {
  description = "Settings for the review policy on the default branch."
  type = object({
    enabled                        = bool
    blocking                       = optional(bool, true)
    reviewer_count                 = optional(number, 2)
    submitter_can_vote             = optional(bool, false)
    last_pusher_cannot_approve     = optional(bool, false)
    complete_with_rejects_or_waits = optional(bool, false)
    reset_votes_on_push            = optional(bool, false)
    require_vote_on_last_iteration = optional(bool, false)
    repository_names               = optional(list(string), [])
    repository_ids                 = optional(list(string), [])
  })
  default = {
    enabled = false
  }
}

variable "work_item_policy" {
  description = "Settings for the work item policy."
  type = object({
    enabled          = bool
    blocking         = optional(bool, true)
    repository_names = optional(list(string), [])
    repository_ids   = optional(list(string), [])
  })
  default = {
    enabled = false
  }
}

variable "comment_policy" {
  description = "Settings for the comment resolution policy."
  type = object({
    enabled          = bool
    blocking         = optional(bool, true)
    repository_names = optional(list(string), [])
    repository_ids   = optional(list(string), [])
  })
  default = {
    enabled = false
  }
}
