resource "azurerm_user_assigned_identity" "aks" {
  name                = "${var.resource_prefix}-msi"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "aks_nodepool" {
  name                = "${var.resource_prefix}-nodepool-msi"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

resource "azurerm_role_assignment" "aks_nodepool_identity" {
  description                      = "Assign the AKS identity Contributor rights to the Nodepool identity."
  principal_id                     = azurerm_user_assigned_identity.aks.principal_id
  skip_service_principal_aad_check = false

  role_definition_name = "Contributor"
  scope                = azurerm_user_assigned_identity.aks_nodepool.id
}
