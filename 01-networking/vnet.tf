# ================================================================================
# VNet 1 — East US, 10.0.0.0/28
# ================================================================================

resource "azurerm_virtual_network" "vnet1" {
  name                = "vwan-vnet1"
  location            = "East US"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/28"]
}

resource "azurerm_subnet" "subnet1" {
  name                 = "vwan-subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.0.0/28"]
}

resource "azurerm_public_ip" "nat_pip1" {
  name                = "vwan-nat-pip1"
  location            = "East US"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat1" {
  name                = "vwan-nat1"
  location            = "East US"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat1_pip" {
  nat_gateway_id       = azurerm_nat_gateway.nat1.id
  public_ip_address_id = azurerm_public_ip.nat_pip1.id
}

resource "azurerm_subnet_nat_gateway_association" "subnet1_nat" {
  subnet_id      = azurerm_subnet.subnet1.id
  nat_gateway_id = azurerm_nat_gateway.nat1.id
}

# ================================================================================
# VNet 2 — East US 2, 172.16.0.0/28
# ================================================================================

resource "azurerm_virtual_network" "vnet2" {
  name                = "vwan-vnet2"
  location            = "East US 2"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["172.16.0.0/28"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "vwan-subnet2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["172.16.0.0/28"]
}

resource "azurerm_public_ip" "nat_pip2" {
  name                = "vwan-nat-pip2"
  location            = "East US 2"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat2" {
  name                = "vwan-nat2"
  location            = "East US 2"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat2_pip" {
  nat_gateway_id       = azurerm_nat_gateway.nat2.id
  public_ip_address_id = azurerm_public_ip.nat_pip2.id
}

resource "azurerm_subnet_nat_gateway_association" "subnet2_nat" {
  subnet_id      = azurerm_subnet.subnet2.id
  nat_gateway_id = azurerm_nat_gateway.nat2.id
}

# ================================================================================
# VNet 3 — West US 2, 192.168.0.0/28
# ================================================================================

resource "azurerm_virtual_network" "vnet3" {
  name                = "vwan-vnet3"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["192.168.0.0/28"]
}

resource "azurerm_subnet" "subnet3" {
  name                 = "vwan-subnet3"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet3.name
  address_prefixes     = ["192.168.0.0/28"]
}

resource "azurerm_public_ip" "nat_pip3" {
  name                = "vwan-nat-pip3"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat3" {
  name                = "vwan-nat3"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat3_pip" {
  nat_gateway_id       = azurerm_nat_gateway.nat3.id
  public_ip_address_id = azurerm_public_ip.nat_pip3.id
}

resource "azurerm_subnet_nat_gateway_association" "subnet3_nat" {
  subnet_id      = azurerm_subnet.subnet3.id
  nat_gateway_id = azurerm_nat_gateway.nat3.id
}
