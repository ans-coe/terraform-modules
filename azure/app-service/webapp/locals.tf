locals {
  is_linux          = var.os_type == "Linux"
  app_service       = local.is_linux ? azurerm_linux_web_app.main[0] : azurerm_windows_web_app.main[0]
  app_service_slots = local.is_linux ? azurerm_linux_web_app_slot.main : azurerm_windows_web_app_slot.main

  default_app_settings = merge(
    var.zip_deploy_file != null ? {
      WEBSITE_RUN_FROM_PACKAGE = "1"
    } : {},
    var.create_application_insights ? {
      ApplicationInsightsAgent_EXTENSION_VERSION      = "~3"
      APPLICATIONINSIGHTS_CONNECTION_STRING           = one(azurerm_application_insights.main[*].connection_string)
      APPLICATIONINSIGHTS_CONFIGURATION_CONTENT       = ""
      APPINSIGHTS_INSTRUMENTATIONKEY                  = one(azurerm_application_insights.main[*].instrumentation_key)
      APPINSIGHTS_PROFILERFEATURE_VERSION             = "1.0.0"
      APPINSIGHTS_SNAPSHOTFEATURE_VERSION             = "1.0.0"
      XDT_MicrosoftApplicationInsights_BaseExtensions = "disabled"
      XDT_MicrosoftApplicationInsights_Mode           = "recommended"
      XDT_MicrosoftApplicationInsights_PreemptSdk     = "disabled"
      DiagnosticServices_EXTENSION_VERSION            = "~3"
      InstrumentationEngine_EXTENSION_VERSION         = "disabled"
      SnapshotDebugger_EXTENSION_VERSION              = "disabled"
    } : {}
  )

  app_settings = merge(local.default_app_settings, var.app_settings)

  default_sticky_app_settings = concat(
    # Application Insights
    [
      "ApplicationInsightsAgent_EXTENSION_VERSION",
      "APPLICATIONINSIGHTS_CONNECTION_STRING",
      "APPLICATIONINSIGHTS_CONFIGURATION_CONTENT",
      "APPINSIGHTS_INSTRUMENTATIONKEY",
      "APPINSIGHTS_PROFILERFEATURE_VERSION",
      "APPINSIGHTS_SNAPSHOTFEATURE_VERSION",
      "XDT_MicrosoftApplicationInsights_BaseExtensions",
      "XDT_MicrosoftApplicationInsights_Mode",
      "XDT_MicrosoftApplicationInsights_PreemptSdk",
      "XDT_MicrosoftApplicationInsightsJava",
      "XDT_MicrosoftApplicationInsights_NodeJS",
      "DiagnosticServices_EXTENSION_VERSION",
      "InstrumentationEngine_EXTENSION_VERSION",
      "SnapshotDebugger_EXTENSION_VERSION"
    ],
    # Authentication
    [
      "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
    ]
  )
  sticky_app_settings = concat(local.default_sticky_app_settings, var.sticky_app_settings)

  ip_restriction_defaults = {
    action                    = "Allow"
    ip_address                = null
    virtual_network_subnet_id = null
    service_tag               = null
    headers                   = null
  }

  allowed_subnet_ids = [
    for id in var.allowed_subnet_ids
    : merge(local.ip_restriction_defaults, {
      name     = "ip_restriction_subnet_id_${join("", [1, index(var.allowed_subnet_ids, id)])}"
      priority = join("", [1, index(var.allowed_subnet_ids, id)])

      virtual_network_subnet_id = id
    })
  ]

  allowed_service_tags = [
    for st in var.allowed_service_tags
    : merge(local.ip_restriction_defaults, {
      name     = "ip_restriction_service_tag_${join("", [2, index(var.allowed_service_tags, st)])}"
      priority = join("", [2, index(var.allowed_service_tags, st)])

      service_tag = st
    })
  ]

  allowed_ips = [
    for ip in var.allowed_ips
    : merge(local.ip_restriction_defaults, {
      name     = "ip_restriction_cidr_${join("", [3, index(var.allowed_ips, ip)])}"
      priority = join("", [3, index(var.allowed_ips, ip)])

      ip_address = ip
    })
  ]

  allowed_frontdoor_ids = length(var.allowed_frontdoor_ids) == 0 ? [] : [
    merge(local.ip_restriction_defaults, {
      name     = "ip_restriction_frontdoor_5"
      priority = 5

      service_tag = "AzureFrontDoor.Backend"
      headers = [{
        x_azure_fdid      = var.allowed_frontdoor_ids
        x_fd_health_probe = null
        x_forwarded_for   = null
        x_forwarded_host  = null
      }]
    })
  ]

  access_rules = concat(
    local.allowed_subnet_ids, local.allowed_service_tags,
    local.allowed_ips, local.allowed_frontdoor_ids
  )

  allowed_scm_subnet_ids = [
    for id in var.allowed_scm_subnet_ids
    : merge(local.ip_restriction_defaults, {
      name     = "ip_restriction_subnet_id_${join("", [1, index(var.allowed_scm_subnet_ids, id)])}"
      priority = join("", [1, index(var.allowed_scm_subnet_ids, id)])

      virtual_network_subnet_id = id
    })
  ]

  allowed_scm_service_tags = [
    for st in var.allowed_scm_service_tags
    : merge(local.ip_restriction_defaults, {
      name     = "ip_restriction_service_tag_${join("", [2, index(var.allowed_scm_service_tags, st)])}"
      priority = join("", [2, index(var.allowed_scm_service_tags, st)])

      service_tag = st
    })
  ]

  allowed_scm_ips = [
    for ip in var.allowed_scm_ips
    : merge(local.ip_restriction_defaults, {
      name     = "scm_ip_restriction_cidr_${join("", [3, index(var.allowed_scm_ips, ip)])}"
      priority = join("", [3, index(var.allowed_scm_ips, ip)])

      ip_address = ip
    })
  ]

  scm_access_rules = concat(
    local.allowed_scm_subnet_ids, local.allowed_scm_service_tags,
    local.allowed_scm_ips
  )

  #### TLS & umid

  use_tls                             = var.cert_options != null
  use_managed_app_service_certificate = local.use_tls ? (var.cert_options.pfx_blob == null && var.cert_options.key_vault == null) : false
  use_app_service_certificate         = local.use_tls ? !local.use_managed_app_service_certificate : false // if we want to use non managed certificate, we set use_managed_certificate to false
  pfx_blob                            = local.use_tls ? var.cert_options.pfx_blob : null
  password                            = local.use_tls ? var.cert_options.password : null
  use_key_vault                       = local.use_tls ? var.cert_options.key_vault != null : false
  create_key_vault                    = local.use_key_vault ? var.cert_options.key_vault.key_vault_secret_id == null : false
  certificate_name                    = local.use_key_vault ? var.cert_options.key_vault.certificate_name : ""
  key_vault_name                      = local.use_key_vault ? coalesce(var.cert_options.key_vault.key_vault_custom_name, "kv-${var.name}") : ""
  key_vault_secret_id                 = local.use_key_vault ? coalesce(one(azurerm_key_vault_certificate.main[*].id), var.cert_options.key_vault.key_vault_secret_id) : null

  use_umid          = try(var.identity_options.use_umid, false)
  umid_name         = local.use_umid ? coalesce(var.identity_options.umid_custom_name, "umid-${var.name}") : ""
  create_umid       = local.use_umid ? var.identity_options.umid_id == null : false
  umid_id           = local.use_umid ? coalesce(one(azurerm_user_assigned_identity.main[*].id), var.identity_options.umid_id) : null
  umid_principal_id = try(one(azurerm_user_assigned_identity.main[*].principal_id), null)

  ### Autoscaling

  use_autoscaling = var.autoscaling != null

}

