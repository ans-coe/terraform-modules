locals {
  default_frontend_ports = {
    "http"  = 80
    "https" = 443
  }
  enable_autoscaling = var.sku.max_capacity != null // If max capacity is set, enable autoscalling. By variable validation, max capacity must be greater capacity

  use_waf = (
    anytrue([
      var.waf_configuration != null,           // Is waf_configuration set?
      var.listener_waf_configuration != null,  // Is listener_waf_configuration set?
      var.path_rule_waf_configuration != null, // Is path_rule_waf_configuration set?
    ])
  )

  // we replace _ with - for keyvault cert names but only in the value of the map. This is due to Keyvault limitations.
  kv_cert_map = { for c, v in var.ssl_certificates
    : c => replace(c, "_", "-") if alltrue([
      v.key_vault_secret_id == null,
      v.data == null,
      v.password == null
    ])
  }

  create_key_vault = alltrue([var.key_vault_id == null, var.use_key_vault])

  listener_policy_map = { for pl in flatten([for k, v in coalesce(var.listener_waf_configuration, {}) :
    [for l in v.associated_listeners : {
      listener = l
      policy   = k
    }]
  ]) : pl.listener => pl.policy }

  ## The above works like so:
  # Input:
  # listener_waf_configuration = {
  #   Z = {
  #     associated_listeners = [X,Y]
  #   }
  #   A = {
  #     associated_listeners = [B,C]
  #   }
  # }
  #
  # Intermediary
  # [
  #   {
  #     listener = X
  #     policy = Z
  #   },
  #   {
  #     listener = Y
  #     policy = Z
  #   }
  # ]
  # Output:
  # listener_policy_map = {
  #   LISTENER_NAME = "POLICY ID"
  #   LISTENER_NAME1 = "POLICY ID"
  #   LISTENER_NAME2 = "POLICY ID"
  # }

  path_rule_policy_map = { for ppr in flatten([for k, v in coalesce(var.path_rule_waf_configuration, {}) :
    [for l in v.associated_path_rules : {
      path_rule = l
      policy    = k
    }]
  ]) : ppr.path_rule => ppr.policy }
}