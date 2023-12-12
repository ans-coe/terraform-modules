locals {
  // We need to create a local for application stack that filters out keys with null value
  application_stack_keys = [
    for k, v in var.application_stack :
    k if v != null
  ]
}

resource "null_resource" "validation" {
  lifecycle {
    precondition {
      error_message = "If os_type is Windows, you can only use Windows Application Stack Variables"
      condition = !local.is_linux ? alltrue([for attr in local.application_stack_keys
        : !contains(
          [ // List of invalid attributes (aka Linux only ones)
            "go_version",
            "java_server",
            "java_server_version",
            "python_version",
            "ruby_version"
        ], attr)]
      ) : true
    }
    precondition {
      error_message = "If os_type is Linux, you can only use Linux Application Stack Variables"
      condition = local.is_linux ? alltrue([for attr in local.application_stack_keys
        : !contains(
          [ // List of invalid attributes (aka Windows only ones)
            "current_stack",
            "dotnet_core_version",
            "tomcat_version",
            "java_embedded_server_enabled",
            "python"
        ], attr)]
      ) : true
    }
    precondition {
      error_message = "If os_type is Linux, virtual_application must be unset (or an empty map)"
      condition     = local.is_linux ? var.virtual_application == {} : true
    }

    precondition {
      error_message = "If you specify cert_options, you must set custom_domain"
      condition     = local.use_tls ? var.custom_domain != null : true
    }
  }
}