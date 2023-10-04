locals {
  default_frontend_ports = {
    "http"  = 80
    "https" = 443
  }
  enable_autoscaling = var.sku.max_capacity != null // If max capacity is set, enable autoscalling. By variable validation, max capacity must be greater capacity

  // we replace _ with - for keyvault cert names but only in the value of the map. This is due to Keyvault limitations.
  kv_cert_map = { for c, v in var.ssl_certificates
    : c => replace(c, "_", "-") if alltrue([
      v.key_vault_secret_id == null,
      v.data == null,
      v.password == null
    ])
  }

  create_key_vault = alltrue([var.key_vault_id == null, var.use_key_vault])
}