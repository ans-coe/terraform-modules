resource "null_resource" "validation" {
  lifecycle {
    precondition {
      error_message = "If os_type is Windows, you can only use Windows Application Stack Variables"
      condition = var.os_type == "Windows" ? alltrue([for attr in keys(var.application_stack)
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
      condition = var.os_type == "Linux" ? alltrue([for attr in keys(var.application_stack)
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
      condition     = var.os_type == "Linux" ? var.virtual_application == {} : true
    }
  }
}