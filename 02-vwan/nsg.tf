# ================================================================================
# Network Security Groups — one per VNet
# Allow HTTP from all three VNet CIDRs; unrestricted egress
# ================================================================================

resource "azurerm_network_security_group" "nsg1" {
  name                = "vwan-nsg1"
  location            = "East US"
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-http-from-vnets"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = ["10.0.0.0/28", "172.16.0.0/28", "192.168.0.0/28"]
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg1_assoc" {
  subnet_id                 = var.subnet1_id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

resource "azurerm_network_security_group" "nsg2" {
  name                = "vwan-nsg2"
  location            = "East US 2"
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-http-from-vnets"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = ["10.0.0.0/28", "172.16.0.0/28", "192.168.0.0/28"]
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg2_assoc" {
  subnet_id                 = var.subnet2_id
  network_security_group_id = azurerm_network_security_group.nsg2.id
}

resource "azurerm_network_security_group" "nsg3" {
  name                = "vwan-nsg3"
  location            = "Central US"
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-http-from-vnets"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = ["10.0.0.0/28", "172.16.0.0/28", "192.168.0.0/28"]
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg3_assoc" {
  subnet_id                 = var.subnet3_id
  network_security_group_id = azurerm_network_security_group.nsg3.id
}
