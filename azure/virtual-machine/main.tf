resource "azurerm_public_ip" "main" {
  count = var.enable_public_ip ? 1 : 0

  name                = "pip-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  allocation_method = var.public_ip_allocation_method
  domain_name_label = var.public_ip_hostname
}

resource "azurerm_network_interface" "main" {
  name                = "nic-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  enable_ip_forwarding = var.enable_ip_forwarding
  dns_servers          = var.dns_servers

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.ip_address != null ? "Static" : "Dynamic"
    private_ip_address            = var.ip_address != null ? var.ip_address : null
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.main[0].id : null
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  for_each = var.backend_address_pool_ids

  ip_configuration_name   = one(azurerm_network_interface.main.ip_configuration[*].name)
  network_interface_id    = azurerm_network_interface.main.id
  backend_address_pool_id = each.value
}

resource "azurerm_network_interface_security_group_association" "main" {
  count = var.enable_network_security_group ? 1 : 0

  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = var.network_security_group_id
}
