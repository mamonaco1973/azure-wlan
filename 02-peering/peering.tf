# ================================================================================
# VNet Peering — full mesh, 6 resources (2 per pair, one each direction)
# Azure peering is non-transitive — all 3 pairs required for full connectivity
# Provisions in seconds vs 20-30 min per hub with vWAN
# ================================================================================

resource "azurerm_virtual_network_peering" "vnet1_to_vnet2" {
  name                      = "vnet1-to-vnet2"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = "vwan-vnet1"
  remote_virtual_network_id = var.vnet2_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "vnet2_to_vnet1" {
  name                      = "vnet2-to-vnet1"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = "vwan-vnet2"
  remote_virtual_network_id = var.vnet1_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "vnet1_to_vnet3" {
  name                      = "vnet1-to-vnet3"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = "vwan-vnet1"
  remote_virtual_network_id = var.vnet3_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "vnet3_to_vnet1" {
  name                      = "vnet3-to-vnet1"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = "vwan-vnet3"
  remote_virtual_network_id = var.vnet1_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "vnet2_to_vnet3" {
  name                      = "vnet2-to-vnet3"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = "vwan-vnet2"
  remote_virtual_network_id = var.vnet3_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "vnet3_to_vnet2" {
  name                      = "vnet3-to-vnet2"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = "vwan-vnet3"
  remote_virtual_network_id = var.vnet2_id
  allow_forwarded_traffic   = true
}
