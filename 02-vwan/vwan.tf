# ================================================================================
# Virtual WAN — Standard tier required for full inter-hub routing
# Note: hub provisioning typically takes 20-30 minutes
# ================================================================================

resource "azurerm_virtual_wan" "vwan" {
  name                = "vwan-demo"
  resource_group_name = var.resource_group_name
  location            = "East US"
  type                = "Standard"
}

# ================================================================================
# Virtual Hubs — one per region
# Hub address prefixes use CGNAT space (100.64/65/66.x) to avoid VNet conflicts
# Inter-hub routing is automatic in vWAN Standard — no explicit peering needed
# ================================================================================

resource "azurerm_virtual_hub" "hub1" {
  name                = "vwan-hub-eastus"
  resource_group_name = var.resource_group_name
  location            = "East US"
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = "100.64.0.0/24"
  sku                 = "Standard"
}

resource "azurerm_virtual_hub" "hub2" {
  name                = "vwan-hub-eastus2"
  resource_group_name = var.resource_group_name
  location            = "East US 2"
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = "100.65.0.0/24"
  sku                 = "Standard"
}

resource "azurerm_virtual_hub" "hub3" {
  name                = "vwan-hub-centralus"
  resource_group_name = var.resource_group_name
  location            = "Central US"
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = "100.66.0.0/24"
  sku                 = "Standard"
}

# ================================================================================
# VNet Connections — attach each VNet to its regional hub
# vWAN injects routes for all connected VNets into each VNet's effective route table
# ================================================================================

resource "azurerm_virtual_hub_connection" "vnet1_conn" {
  name                      = "vwan-vnet1-conn"
  virtual_hub_id            = azurerm_virtual_hub.hub1.id
  remote_virtual_network_id = var.vnet1_id
}

resource "azurerm_virtual_hub_connection" "vnet2_conn" {
  name                      = "vwan-vnet2-conn"
  virtual_hub_id            = azurerm_virtual_hub.hub2.id
  remote_virtual_network_id = var.vnet2_id
}

resource "azurerm_virtual_hub_connection" "vnet3_conn" {
  name                      = "vwan-vnet3-conn"
  virtual_hub_id            = azurerm_virtual_hub.hub3.id
  remote_virtual_network_id = var.vnet3_id
}
