module "external-parties-workspace" {

  source              = "../../modules/avd-workspace"
  avd_workspace_name  = ""
  resource_group_name = ""
  location            = var.location
  workspace_config = {
    description                   = ""
    friendly_name                 = ""
    public_network_access_enabled = true
  }
  ## tags ##
  application         = "vdws"
  workload_name       = local.default_tags.workload_name
  owner               = local.default_tags.owner
  service_tier        = local.default_tags.service_tier
  data_classification = local.default_tags.data_classification
  support_contact     = local.default_tags.support_contact
  environment         = local.default_tags.environment
  charge_code         = local.default_tags.charge_code
  criticality         = local.default_tags.criticality
  lbsPatchDefinitions = local.default_tags.lbsPatchDefinitions

  extra_tags = {}
}

module "external-parties-validation-workspace" {

  source              = "../../modules/avd-workspace"
  avd_workspace_name  = ""
  resource_group_name = ""
  location            = var.location
  workspace_config = {
    description                   = ""
    friendly_name                 = ""
    public_network_access_enabled = true
  }
  ## tags ##
  application         = "vdws"
  workload_name       = local.default_tags.workload_name
  owner               = local.default_tags.owner
  service_tier        = local.default_tags.service_tier
  data_classification = local.default_tags.data_classification
  support_contact     = local.default_tags.support_contact
  environment         = local.default_tags.environment
  charge_code         = local.default_tags.charge_code
  criticality         = local.default_tags.criticality
  lbsPatchDefinitions = local.default_tags.lbsPatchDefinitions

  extra_tags = {}
}


module "external-parties-hostpool" {

  source              = "../../modules/avd-host-pool"
  avd_host_pool_name  = ""
  location            = var.location
  resource_group_name = ""

  host_pool_config = {
    friendly_name            = ""
    description              = ""
    preferred_app_group_type = "Desktop"
    start_vm_on_connect      = true
    validate_environment     = false
    load_balancer_type       = "DepthFirst"
    maximum_sessions_allowed = 16
    type                     = "Pooled"
    scheduled_agent_updates = {
      enabled  = true
      timezone = local.timezone
      schedules = [
        {
          day_of_week = "Sunday"
          hour_of_day = 8
        },
        {
          day_of_week = "Wednesday"
          hour_of_day = 22
        },
      ]
    }
  }
  ## tags ##
  application         = "vdpool"
  workload_name       = local.default_tags.workload_name
  owner               = local.default_tags.owner
  service_tier        = local.default_tags.service_tier
  data_classification = local.default_tags.data_classification
  support_contact     = local.default_tags.support_contact
  environment         = local.default_tags.environment
  charge_code         = local.default_tags.charge_code
  criticality         = local.default_tags.criticality
  lbsPatchDefinitions = local.default_tags.lbsPatchDefinitions

  extra_tags = {}
}


module "external-parties-validation-hostpool" {

  source              = "../../modules/avd-host-pool"
  avd_host_pool_name  = ""
  location            = var.location
  resource_group_name = ""

  host_pool_config = {
    friendly_name            = ""
    description              = ""
    preferred_app_group_type = "Desktop"
    start_vm_on_connect      = true
    validate_environment     = true
    load_balancer_type       = "DepthFirst"
    maximum_sessions_allowed = 16
    type                     = "Pooled"
    scheduled_agent_updates = {
      enabled  = true
      timezone = local.timezone
      schedules = [
        {
          day_of_week = "Sunday"
          hour_of_day = 8
        },
        {
          day_of_week = "Wednesday"
          hour_of_day = 22
        },
      ]
    }
  }
  ## tags ##
  application         = "vdpool"
  workload_name       = local.default_tags.workload_name
  owner               = local.default_tags.owner
  service_tier        = local.default_tags.service_tier
  data_classification = local.default_tags.data_classification
  support_contact     = local.default_tags.support_contact
  environment         = local.default_tags.environment
  charge_code         = local.default_tags.charge_code
  criticality         = local.default_tags.criticality
  lbsPatchDefinitions = local.default_tags.lbsPatchDefinitions

  extra_tags = {}
}


module "microsoft-edge-application-group" {

  source              = "../../modules/avd-app-group"
  avd_app_group_name  = ""
  resource_group_name = ""
  location            = var.location
  workspace_id        = module.external-parties-workspace.workspace_id
  host_pool_id        = module.external-parties-hostpool.avd_host_pool_id

  application_group_config = {
    description   = "Application Group for Microsoft Edge"
    friendly_name = "Microsoft Edge"
    type          = "RemoteApp"

    # TBC
    # role_assignments_object_ids = concat(
    #   data.azuread_group.avd_group.members,
    #   [
    #     local.avd_user_01_object_id,
    #     local.avd_user_02_object_id,
    #   ],
    # )
  }
  ## tags ##
  application         = "vdag"
  workload_name       = local.default_tags.workload_name
  owner               = local.default_tags.owner
  service_tier        = local.default_tags.service_tier
  data_classification = local.default_tags.data_classification
  support_contact     = local.default_tags.support_contact
  environment         = local.default_tags.environment
  charge_code         = local.default_tags.charge_code
  criticality         = local.default_tags.criticality
  lbsPatchDefinitions = local.default_tags.lbsPatchDefinitions

  extra_tags = {}
}

module "sql-server-management-studio-application-group" {

  source              = "../../modules/avd-app-group"
  avd_app_group_name  = ""
  resource_group_name = ""
  location            = var.location
  workspace_id        = module.external-parties-workspace.workspace_id
  host_pool_id        = module.external-parties-hostpool.avd_host_pool_id

  application_group_config = {
    description   = "Application Group for SQL Server Management Studio"
    friendly_name = "SQL Server Management Studio"
    type          = "RemoteApp"

    # TBC
    # role_assignments_object_ids = concat(
    #   data.azuread_group.avd_group.members,
    #   [
    #     local.avd_user_01_object_id,
    #     local.avd_user_02_object_id,
    #   ],
    # )
  }
  ## tags ##
  application         = "vdag"
  workload_name       = local.default_tags.workload_name
  owner               = local.default_tags.owner
  service_tier        = local.default_tags.service_tier
  data_classification = local.default_tags.data_classification
  support_contact     = local.default_tags.support_contact
  environment         = local.default_tags.environment
  charge_code         = local.default_tags.charge_code
  criticality         = local.default_tags.criticality
  lbsPatchDefinitions = local.default_tags.lbsPatchDefinitions

  extra_tags = {}
}


module "azure-cli-application-group" {

  source              = "../../modules/avd-app-group"
  avd_app_group_name  = ""
  resource_group_name = ""
  location            = var.location
  workspace_id        = module.external-parties-workspace.workspace_id
  host_pool_id        = module.external-parties-hostpool.avd_host_pool_id
  application_group_config = {
    description   = "Application Group for Azure CLI"
    friendly_name = "Azure CLI"
    type          = "RemoteApp"

    # TBC
    # role_assignments_object_ids = concat(
    #   data.azuread_group.avd_group.members,
    #   [
    #     local.avd_user_01_object_id,
    #     local.avd_user_02_object_id,
    #   ],
    # )
  }
  ## tags ##
  application         = "vdag"
  workload_name       = local.default_tags.workload_name
  owner               = local.default_tags.owner
  service_tier        = local.default_tags.service_tier
  data_classification = local.default_tags.data_classification
  support_contact     = local.default_tags.support_contact
  environment         = local.default_tags.environment
  charge_code         = local.default_tags.charge_code
  criticality         = local.default_tags.criticality
  lbsPatchDefinitions = local.default_tags.lbsPatchDefinitions

  extra_tags = {}
}


module "visual-studio-code-application-group" {

  source              = "../../modules/avd-app-group"
  avd_app_group_name  = ""
  resource_group_name = ""
  location            = var.location
  workspace_id        = module.external-parties-workspace.workspace_id
  host_pool_id        = module.external-parties-hostpool.avd_host_pool_id
  application_group_config = {
    description   = "Application Group for Visual Studio Code"
    friendly_name = "Visual Studio Code"
    type          = "RemoteApp"

    # TBC
    # role_assignments_object_ids = concat(
    #   data.azuread_group.avd_group.members,
    #   [
    #     local.avd_user_01_object_id,
    #     local.avd_user_02_object_id,
    #   ],
    # )
  }
  ## tags ##
  application         = "vdag"
  workload_name       = local.default_tags.workload_name
  owner               = local.default_tags.owner
  service_tier        = local.default_tags.service_tier
  data_classification = local.default_tags.data_classification
  support_contact     = local.default_tags.support_contact
  environment         = local.default_tags.environment
  charge_code         = local.default_tags.charge_code
  criticality         = local.default_tags.criticality
  lbsPatchDefinitions = local.default_tags.lbsPatchDefinitions

  extra_tags = {}
}

module "jetbrains-ide-application-group" {

  source              = "../../modules/avd-app-group"
  avd_app_group_name  = ""
  resource_group_name = ""
  location            = var.location
  workspace_id        = module.external-parties-workspace.workspace_id
  host_pool_id        = module.external-parties-hostpool.avd_host_pool_id
  application_group_config = {
    description   = ""
    friendly_name = ""
    type          = "RemoteApp"

    # TBC
    # role_assignments_object_ids = concat(
    #   data.azuread_group.avd_group.members,
    #   [
    #     local.avd_user_01_object_id,
    #     local.avd_user_02_object_id,
    #   ],
    # )
  }
  ## tags ##
  application         = "vdag"
  workload_name       = local.default_tags.workload_name
  owner               = local.default_tags.owner
  service_tier        = local.default_tags.service_tier
  data_classification = local.default_tags.data_classification
  support_contact     = local.default_tags.support_contact
  environment         = local.default_tags.environment
  charge_code         = local.default_tags.charge_code
  criticality         = local.default_tags.criticality
  lbsPatchDefinitions = local.default_tags.lbsPatchDefinitions

  extra_tags = {}
}


module "scaling_plan" {

  source                = "../../modules/avd-auto-scaling"
  avd_scaling_plan_name = ""
  resource_group_name   = ""
  location              = var.location
  hostpool_id           = module.external-parties-hostpool.avd_host_pool_id

  scaling_plan_config = {
    enabled       = true
    description   = ""
    friendly_name = ""
    timezone      = local.timezone
    exclusion_tag = "Tag Name: ScalingDisabled"
    schedules = [
      {
        name                                 = "weekdays"
        days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        ramp_up_start_time                   = "08:00"
        peak_start_time                      = "09:00"
        ramp_down_start_time                 = "18:00"
        off_peak_start_time                  = "20:00"
        ramp_down_load_balancing_algorithm   = "DepthFirst"
        ramp_up_capacity_threshold_percent   = 80
        ramp_down_capacity_threshold_percent = 90
        ramp_down_wait_time_minutes          = 30
        ramp_up_minimum_hosts_percent        = 0
        ramp_down_minimum_hosts_percent      = 0
        ramp_down_force_logoff_users         = true
        ramp_down_notification_message       = "You will be logged off in 30 min. To prevent losing any work, please save it in OneDrive or SharePoint now."
      },
      {
        name                                 = "weekend"
        days_of_week                         = ["Saturday", "Sunday"]
        ramp_up_start_time                   = "09:00"
        peak_start_time                      = "11:00"
        ramp_down_start_time                 = "16:00"
        off_peak_start_time                  = "20:00"
        ramp_down_load_balancing_algorithm   = "DepthFirst"
        ramp_up_capacity_threshold_percent   = 80
        ramp_down_capacity_threshold_percent = 90
        ramp_down_wait_time_minutes          = 30
        ramp_up_minimum_hosts_percent        = 0
        ramp_down_minimum_hosts_percent      = 0
        ramp_down_force_logoff_users         = true
        ramp_down_notification_message       = "You will be logged off in 30 min. Make sure to save your work.”"
      },
    ]
    # role_assignment = {
    #   enabled   = false                                   # `false` if you do not have permission to create the Role and the Role Assignment, but this must be done somehow
    #   object_id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeeee" # In case you do not have permsision to retrieve the object ID of the AVD Service Principal
    # }
  }
  ## tags ##
  application         = "vdscaling"
  workload_name       = local.default_tags.workload_name
  owner               = local.default_tags.owner
  service_tier        = local.default_tags.service_tier
  data_classification = local.default_tags.data_classification
  support_contact     = local.default_tags.support_contact
  environment         = local.default_tags.environment
  charge_code         = local.default_tags.charge_code
  criticality         = local.default_tags.criticality
  lbsPatchDefinitions = local.default_tags.lbsPatchDefinitions

  extra_tags = {}
}
