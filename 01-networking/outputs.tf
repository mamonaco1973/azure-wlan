output "resource_group_name" { value = azurerm_resource_group.rg.name }

output "vnet1_id" { value = azurerm_virtual_network.vnet1.id }
output "vnet2_id" { value = azurerm_virtual_network.vnet2.id }
output "vnet3_id" { value = azurerm_virtual_network.vnet3.id }

output "subnet1_id" { value = azurerm_subnet.subnet1.id }
output "subnet2_id" { value = azurerm_subnet.subnet2.id }
output "subnet3_id" { value = azurerm_subnet.subnet3.id }
