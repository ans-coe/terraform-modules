locals {
  default_frontend_ports = {
    "Http"  = 80
    "Https" = 443
  }
  enable_autoscaling = var.sku.max_capacity > var.sku.capacity

  // we replace _ with - for keyvault cert names but only in the value of the map. 
  kv_cert_map = { for c, v in var.ssl_certificates
    : c => replace(c, "_", "-") if alltrue([
      v.key_vault_secret_id == null,
      v.data == null,
      v.password == null
    ])
  }

  create_key_vault = alltrue([var.key_vault_id == null, var.create_key_vault])
  use_keyvault      = !alltrue([var.key_vault_id == null, !var.create_key_vault])
}