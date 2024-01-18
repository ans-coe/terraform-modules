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
      error_message = "If you specify cert_options, you must set custom_domain"
      condition     = local.use_tls ? var.custom_domain != null : true
    }

    precondition {
      error_message = "if cert_options key_vault is not null, use_umid must be true."
      condition     = local.use_key_vault ? local.use_umid : true
    }
  }
}