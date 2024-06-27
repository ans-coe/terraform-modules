resource "azurerm_public_ip" "main" {
  count = var.enable_public_ip ? 1 : 0

  name                = var.public_ip_name == null ? "pip-${var.name}" : var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  allocation_method = var.public_ip_allocation_method
  domain_name_label = var.public_ip_hostname
}

resource "azurerm_network_interface" "main" {
  name                = var.network_interface_name == null ? "nic-${var.name}" : var.network_interface_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_forwarding_enabled = var.ip_forwarding_enabled

  dns_servers = var.dns_servers

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.ip_address != null ? "Static" : "Dynamic"
    private_ip_address            = var.ip_address != null ? var.ip_address : null
    public_ip_address_id          = one(azurerm_public_ip.main[*].id)
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count = length(var.backend_address_pool_ids)

  ip_configuration_name   = one(azurerm_network_interface.main.ip_configuration[*].name)
  network_interface_id    = azurerm_network_interface.main.id
  backend_address_pool_id = var.backend_address_pool_ids[count.index]
}

resource "azurerm_network_interface_security_group_association" "main" {
  count = var.enable_network_security_group ? 1 : 0

  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = var.network_security_group_id
}

resource "azurerm_virtual_machine_data_disk_attachment" "main" {
  for_each = var.disk_attachments

  virtual_machine_id = local.virtual_machine.id
  managed_disk_id    = each.value["id"]

  lun     = each.value["lun"]
  caching = each.value["caching"]
}

resource "azurerm_backup_protected_vm" "main" {
  count = var.backup_config != null ? 1 : 0

  source_vm_id        = local.virtual_machine.id
  resource_group_name = split("/", var.backup_config["backup_policy_id"])[4]
  recovery_vault_name = split("/", var.backup_config["backup_policy_id"])[8]
  backup_policy_id    = var.backup_config["backup_policy_id"]

  include_disk_luns = var.backup_config["include_disk_luns"]
  exclude_disk_luns = var.backup_config["exclude_disk_luns"]
}
