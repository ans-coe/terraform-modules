data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  count = local.create_key_vault ? 1 : 0

  name                       = local.key_vault_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  tags                       = var.tags
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  sku_name                   = "standard"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_key_vault_access_policy" "operator" {
  count = local.create_key_vault ? 1 : 0

  key_vault_id = azurerm_key_vault.main[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  certificate_permissions = ["Create", "Delete", "Get", "List", "Update", "Recover", "Restore"]

  key_permissions = ["Create", "Delete", "Get", "List", "Update", "Recover", "Restore"]

  secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]

  lifecycle {
    ignore_changes = [object_id, tenant_id]
  }
}

resource "azurerm_key_vault_certificate" "main" {
  count = local.create_key_vault ? 1 : 0

  name         = local.certificate_name
  key_vault_id = azurerm_key_vault.main[0].id

  lifecycle {
    ignore_changes = all
  }

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = ["changeme.example.com"]
      }

      subject            = "CN=changeme"
      validity_in_months = 60
    }
  }
  depends_on = [azurerm_key_vault_access_policy.operator]
}

resource "azurerm_key_vault_access_policy" "main" {
  count = local.create_key_vault ? 1 : 0

  key_vault_id = azurerm_key_vault.main[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.main[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
  certificate_permissions = [
    "Get", "List"
  ]
}

### Link certificate to app service:

resource "azurerm_app_service_certificate" "main" {
  count = local.use_app_service_certificate ? 1 : 0

  name                = local.certificate_name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Key Vault Cert:

  key_vault_secret_id = local.key_vault_secret_id

  # pfx_blob Cert:

  pfx_blob = local.use_key_vault ? null : local.pfx_blob
  password = local.use_key_vault ? null : local.password
}

resource "azurerm_app_service_managed_certificate" "main" {
  count                      = local.use_managed_app_service_certificate ? 1 : 0
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.main[0].id
}

resource "azurerm_app_service_certificate_binding" "main" {
  count               = local.use_tls ? 1 : 0
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.main[0].id
  certificate_id      = local.use_managed_app_service_certificate ? azurerm_app_service_managed_certificate.main[0].id : azurerm_app_service_certificate.main[0].id
  ssl_state           = "SniEnabled"
}