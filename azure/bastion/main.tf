##########
# Bastion
##########

resource "azurerm_public_ip" "main" {
  name                = var.public_ip_name == null ? "pip-${var.name}" : var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  sku               = "Standard"
  allocation_method = "Static"
}

resource "azurerm_bastion_host" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  sku = var.sku

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.main.id
  }

  copy_paste_enabled = true
  file_copy_enabled  = var.sku == "Standard" ? true : false
  scale_units        = var.scale_units

  ip_connect_enabled     = var.sku == "Standard" ? true : false
  shareable_link_enabled = var.sku == "Standard" ? true : false
  tunneling_enabled      = var.sku == "Standard" ? true : false
}

######
# NSG
######

resource "azurerm_network_security_group" "main" {
  name                = var.network_security_group_name == null ? "nsg-${var.name}" : var.network_security_group_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  security_rule {
    name        = "AllowHttpsInbound"
    description = "Allow HTTPS traffic inbound from enabled sources."
    priority    = 120
    direction   = "Inbound"
    access      = "Allow"

    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "443"

    source_address_prefix      = length(var.whitelist) == 1 ? var.whitelist[0] : null
    source_address_prefixes    = length(var.whitelist) > 1 ? var.whitelist : null
    destination_address_prefix = "*"
  }

  security_rule {
    name        = "AllowGatewayManagerInbound"
    description = "Allow HTTPS traffic inbound from the Gateway Manager."
    priority    = 130
    direction   = "Inbound"
    access      = "Allow"

    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "443"

    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name        = "AllowAzureLoadBalancerInbound"
    description = "Allow HTTPS traffic inbound from Azure Load Balancer."
    priority    = 140
    direction   = "Inbound"
    access      = "Allow"

    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "443"

    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name        = "AllowBastionHostCommunication"
    description = "Allow Bastion Dataplane ports inbound."
    priority    = 150
    direction   = "Inbound"
    access      = "Allow"

    protocol                = "*"
    source_port_range       = "*"
    destination_port_ranges = ["8080", "5701"]

    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name        = "AllowSshRdpOutbound"
    description = "Allow SSH and RDP traffic outbound to VirtualNetwork."
    priority    = 100
    direction   = "Outbound"
    access      = "Allow"

    protocol                = "*"
    source_port_range       = "*"
    destination_port_ranges = ["22", "3389"]

    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name        = "AllowAzureCloudOutbound"
    description = "Allow traffic outbound to AzureCloud."
    priority    = 110
    direction   = "Outbound"
    access      = "Allow"

    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "443"

    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }

  security_rule {
    name        = "AllowBastionCommunication"
    description = "Allow Bastion Dataplane ports outbound."
    priority    = 120
    direction   = "Outbound"
    access      = "Allow"

    protocol                = "*"
    source_port_range       = "*"
    destination_port_ranges = ["8080", "5701"]

    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name        = "AllowGetSessionInformation"
    description = "Allow HTTP traffic outbound to Internet for session traffic and certificate validation."
    priority    = 130
    direction   = "Outbound"
    access      = "Allow"

    protocol               = "*"
    source_port_range      = "*"
    destination_port_range = "80"

    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.main.id
}
