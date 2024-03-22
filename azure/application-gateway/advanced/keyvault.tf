data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  count = local.create_key_vault ? 1 : 0

  name                       = var.key_vault_name != null ? var.key_vault_name : "kv-${var.name}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  tags                       = var.tags
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  sku_name                   = "standard"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_key_vault_access_policy" "main_user" {
  count = var.use_key_vault ? 1 : 0

  key_vault_id = var.key_vault_id == null ? azurerm_key_vault.main[0].id : var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  certificate_permissions = ["Create", "Delete", "Get", "List", "Update", "Recover", "Restore", "Import"]

  key_permissions = ["Create", "Delete", "Get", "List", "Update", "Recover", "Restore"]

  secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]

  lifecycle {
    ignore_changes = [object_id, tenant_id]
  }
}

resource "azurerm_key_vault_certificate" "main" {
  // Generate certificates only when one is not provided & only when we have a keyvault to put them in
  for_each = var.use_key_vault ? local.kv_cert_map : {}

  name         = each.value
  key_vault_id = var.key_vault_id == null ? azurerm_key_vault.main[0].id : var.key_vault_id

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
  depends_on = [azurerm_key_vault_access_policy.main_user]
}

resource "azurerm_user_assigned_identity" "main_gateway" {
  count = var.use_key_vault ? 1 : 0

  name                = var.key_vault_user_assigned_identity_name != null ? var.key_vault_user_assigned_identity_name : "umid-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_key_vault_access_policy" "main_gateway" {
  count = var.use_key_vault ? 1 : 0

  key_vault_id = var.key_vault_id == null ? azurerm_key_vault.main[0].id : var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.main_gateway[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
  certificate_permissions = [
    "Get", "List"
  ]
}

