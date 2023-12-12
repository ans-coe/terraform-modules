##############################
#|#     Windows WebApp     #|#
##############################

resource "azurerm_windows_web_app" "main" {
  count = local.is_linux ? 0 : 1

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  service_plan_id           = local.plan_id
  virtual_network_subnet_id = var.subnet_id

  https_only                      = true
  key_vault_reference_identity_id = local.umid_id

  public_network_access_enabled = var.public_network_access_enabled

  zip_deploy_file = var.zip_deploy_file

  site_config {
    application_stack {
      docker_image_name            = var.application_stack.docker_image_name
      docker_registry_url          = var.application_stack.docker_registry_url
      docker_registry_username     = var.application_stack.docker_registry_username
      docker_registry_password     = var.application_stack.docker_registry_password
      dotnet_version               = var.application_stack.dotnet_version
      java_version                 = var.application_stack.java_version
      node_version                 = var.application_stack.node_version
      php_version                  = var.application_stack.php_version
      current_stack                = var.application_stack.current_stack
      dotnet_core_version          = var.application_stack.dotnet_core_version
      tomcat_version               = var.application_stack.tomcat_version
      java_embedded_server_enabled = var.application_stack.java_embedded_server_enabled
      python                       = var.application_stack.python
    }

    always_on                                     = var.site_config.always_on
    api_definition_url                            = var.site_config.api_definition_url
    api_management_api_id                         = var.site_config.api_management_api_id
    app_command_line                              = var.site_config.app_command_line
    container_registry_managed_identity_client_id = var.site_config.container_registry_managed_identity_client_id
    container_registry_use_managed_identity       = var.site_config.container_registry_use_managed_identity
    default_documents                             = var.site_config.default_documents
    health_check_eviction_time_in_min             = var.site_config.health_check_eviction_time_in_min
    ftps_state                                    = var.site_config.ftps_state
    health_check_path                             = var.site_config.health_check_path
    http2_enabled                                 = var.site_config.http2_enabled
    load_balancing_mode                           = var.site_config.load_balancing_mode
    local_mysql_enabled                           = var.site_config.local_mysql_enabled
    managed_pipeline_mode                         = var.site_config.managed_pipeline_mode
    minimum_tls_version                           = var.site_config.minimum_tls_version
    scm_minimum_tls_version                       = var.site_config.scm_minimum_tls_version
    scm_use_main_ip_restriction                   = var.site_config.scm_use_main_ip_restriction
    remote_debugging_enabled                      = var.site_config.remote_debugging_enabled
    remote_debugging_version                      = var.site_config.remote_debugging_version
    use_32_bit_worker                             = var.site_config.use_32_bit_worker
    vnet_route_all_enabled                        = var.site_config.vnet_route_all_enabled
    websockets_enabled                            = var.site_config.websockets_enabled
    worker_count                                  = var.site_config.worker_count

    dynamic "cors" {
      for_each = var.cors == null ? [] : [1]
      content {
        allowed_origins     = var.cors.allowed_origins
        support_credentials = var.cors.support_credentials
      }
    }

    dynamic "virtual_application" {
        for_each = var.virtual_application
        content {
          virtual_path  = virtual_application.value.virtual_path
          preload       = virtual_application.value.preload
          physical_path = virtual_application.value.physical_path
          dynamic "virtual_directory" {
            for_each = virtual_application.value.virtual_directories
            content {
              physical_path = virtual_directory.physical_path
              virtual_path  = virtual_directory.virtual_path
            }
          }
        }

      }

    dynamic "ip_restriction" {
      for_each = local.access_rules
      content {
        name     = ip_restriction.name
        priority = ip_restriction.priority
        action   = ip_restriction.action

        ip_address                = ip_restriction.ip_address
        service_tag               = ip_restriction.service_tag
        virtual_network_subnet_id = ip_restriction.virtual_network_subnet_id
        headers                   = ip_restriction.headers
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = local.scm_access_rules
      content {
        name     = scm_ip_restriction.name
        priority = scm_ip_restriction.priority
        action   = scm_ip_restriction.action

        ip_address                = scm_ip_restriction.ip_address
        service_tag               = scm_ip_restriction.service_tag
        virtual_network_subnet_id = scm_ip_restriction.virtual_network_subnet_id
        headers                   = scm_ip_restriction.headers
      }
    }
  }

  app_settings = local.app_settings

  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value["name"]
      type  = connection_string.value["type"]
      value = connection_string.value["value"]
    }
  }

  dynamic "sticky_settings" {
    for_each = length(concat(local.sticky_app_settings, var.sticky_connection_strings)) == 0 ? [] : [1]
    content {
      app_setting_names       = length(local.sticky_app_settings) == 0 ? null : local.sticky_app_settings
      connection_string_names = length(var.sticky_connection_strings) == 0 ? null : var.sticky_connection_strings
    }
  }

  logs {
    detailed_error_messages = var.logs["detailed_error_messages"]
    failed_request_tracing  = var.logs["failed_request_tracing"]

    application_logs {
      file_system_level = var.logs["level"]
    }

    http_logs {
      file_system {
        retention_in_days = var.logs["retention_in_days"]
        retention_in_mb   = var.logs["retention_in_mb"]
      }
    }
  }

  identity {
    type         = local.use_umid ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = local.umid_id != null ? [local.umid_id] : null
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to image tag, as this would be managed elsewhere.
      site_config[0].application_stack[0].docker_container_tag,
      # Ignore blob log configuration - ideally configure through diagnostic setting
      logs[0].application_logs[0].azure_blob_storage,
      logs[0].http_logs[0].azure_blob_storage,
      # Ignore hidden links that when deleted may break functionality
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
      # Configure authentication outside of Terraform
      auth_settings_v2,
      app_settings["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"],
    ]
  }
}

resource "azurerm_windows_web_app_slot" "main" {
  for_each = local.is_linux ? [] : var.slots

  name           = each.value
  app_service_id = azurerm_windows_web_app.main[0].id
  tags           = var.tags

  virtual_network_subnet_id = var.subnet_id

  https_only                      = true
  key_vault_reference_identity_id = local.umid_id

  zip_deploy_file = var.zip_deploy_file

  dynamic "site_config" {
    for_each = [var.site_config]
    content {
      always_on                                     = var.site_config.always_on
      api_definition_url                            = var.site_config.api_definition_url
      api_management_api_id                         = var.site_config.api_management_api_id
      app_command_line                              = var.site_config.app_command_line
      container_registry_managed_identity_client_id = var.site_config.container_registry_managed_identity_client_id
      container_registry_use_managed_identity       = var.site_config.container_registry_use_managed_identity
      default_documents                             = var.site_config.default_documents
      health_check_eviction_time_in_min             = var.site_config.health_check_eviction_time_in_min
      ftps_state                                    = var.site_config.ftps_state
      health_check_path                             = var.site_config.health_check_path
      http2_enabled                                 = var.site_config.http2_enabled
      load_balancing_mode                           = var.site_config.load_balancing_mode
      local_mysql_enabled                           = var.site_config.local_mysql_enabled
      managed_pipeline_mode                         = var.site_config.managed_pipeline_mode
      minimum_tls_version                           = var.site_config.minimum_tls_version
      scm_minimum_tls_version                       = var.site_config.scm_minimum_tls_version
      scm_use_main_ip_restriction                   = var.site_config.scm_use_main_ip_restriction
      remote_debugging_enabled                      = var.site_config.remote_debugging_enabled
      remote_debugging_version                      = var.site_config.remote_debugging_version
      use_32_bit_worker                             = var.site_config.use_32_bit_worker
      vnet_route_all_enabled                        = var.site_config.vnet_route_all_enabled
      websockets_enabled                            = var.site_config.websockets_enabled
      worker_count                                  = var.site_config.worker_count

      dynamic "ip_restriction" {
        for_each = local.access_rules
        content {
          name     = ip_restriction.name
          priority = ip_restriction.priority
          action   = ip_restriction.action

          ip_address                = ip_restriction.ip_address
          service_tag               = ip_restriction.service_tag
          virtual_network_subnet_id = ip_restriction.virtual_network_subnet_id
          headers                   = ip_restriction.headers
        }
      }
      dynamic "scm_ip_restriction" {
        for_each = local.access_rules
        content {
          name     = scm_ip_restriction.name
          priority = scm_ip_restriction.priority
          action   = scm_ip_restriction.action

          ip_address                = scm_ip_restriction.ip_address
          service_tag               = scm_ip_restriction.service_tag
          virtual_network_subnet_id = scm_ip_restriction.virtual_network_subnet_id
          headers                   = scm_ip_restriction.headers
        }
      }

      dynamic "cors" {
        for_each = var.cors == null ? [] : [1]
        content {
          allowed_origins     = var.cors.allowed_origins
          support_credentials = var.cors.support_credentials
        }
      }

      application_stack {
        docker_image_name            = var.application_stack.docker_image_name
        docker_registry_url          = var.application_stack.docker_registry_url
        docker_registry_username     = var.application_stack.docker_registry_username
        docker_registry_password     = var.application_stack.docker_registry_password
        dotnet_version               = var.application_stack.dotnet_version
        java_version                 = var.application_stack.java_version
        node_version                 = var.application_stack.node_version
        php_version                  = var.application_stack.php_version
        current_stack                = var.application_stack.current_stack
        dotnet_core_version          = var.application_stack.dotnet_core_version
        tomcat_version               = var.application_stack.tomcat_version
        java_embedded_server_enabled = var.application_stack.java_embedded_server_enabled
        python                       = var.application_stack.python
      }

      dynamic "virtual_application" {
        for_each = var.virtual_application
        content {
          virtual_path  = virtual_application.value.virtual_path
          preload       = virtual_application.value.preload
          physical_path = virtual_application.value.physical_path
          dynamic "virtual_directory" {
            for_each = virtual_application.value.virtual_directories
            content {
              physical_path = virtual_directory.physical_path
              virtual_path  = virtual_directory.virtual_path
            }
          }
        }

      }
    }
  }

  app_settings = local.app_settings
  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value["name"]
      type  = connection_string.value["type"]
      value = connection_string.value["value"]
    }
  }

  logs {
    detailed_error_messages = var.logs["detailed_error_messages"]
    failed_request_tracing  = var.logs["failed_request_tracing"]

    application_logs {
      file_system_level = var.logs["level"]
    }

    http_logs {
      file_system {
        retention_in_days = var.logs["retention_in_days"]
        retention_in_mb   = var.logs["retention_in_mb"]
      }
    }
  }

  identity {
    type         = local.use_umid ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = local.umid_id != null ? [local.umid_id] : null
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to image tag, as this would be managed elsewhere.
      site_config[0].application_stack[0].docker_container_tag,
      # Ignore blob log configuration - ideally configure through diagnostic setting
      logs[0].application_logs[0].azure_blob_storage,
      logs[0].http_logs[0].azure_blob_storage,
      # Ignore hidden links that when deleted may break functionality
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
      # Configure authentication outside of Terraform
      auth_settings_v2,
      app_settings["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"],
    ]
  }
}