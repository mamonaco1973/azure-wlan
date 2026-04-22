output "resource_group_name" { value = var.resource_group_name }

output "vm1_name"       { value = azurerm_linux_virtual_machine.vm1.name }
output "vm2_name"       { value = azurerm_linux_virtual_machine.vm2.name }
output "vm3_name"       { value = azurerm_linux_virtual_machine.vm3.name }

output "vm1_private_ip" { value = azurerm_network_interface.nic1.private_ip_address }
output "vm2_private_ip" { value = azurerm_network_interface.nic2.private_ip_address }
output "vm3_private_ip" { value = azurerm_network_interface.nic3.private_ip_address }
