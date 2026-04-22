# ================================================================================
# VMs — one per VNet
# Ubuntu 22.04, no public IP; nginx serves the identity response via custom_data
# az vm run-command replaces SSM for out-of-band command execution
# ================================================================================

resource "azurerm_network_interface" "nic1" {
  name                = "vwan-nic1"
  location            = "East US"
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet1_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name                            = "vwan-vm1"
  location                        = "East US"
  resource_group_name             = var.resource_group_name
  size                            = "Standard_B1s"
  admin_username                  = "azureuser"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.nic1.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    IP=$(hostname -I | awk '{print $1}')
    echo "$IP - Welcome to VNet eastus" > /var/www/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOF
  )
}

resource "azurerm_network_interface" "nic2" {
  name                = "vwan-nic2"
  location            = "East US 2"
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet2_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                            = "vwan-vm2"
  location                        = "East US 2"
  resource_group_name             = var.resource_group_name
  size                            = "Standard_B1s"
  admin_username                  = "azureuser"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.nic2.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    IP=$(hostname -I | awk '{print $1}')
    echo "$IP - Welcome to VNet eastus2" > /var/www/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOF
  )
}

resource "azurerm_network_interface" "nic3" {
  name                = "vwan-nic3"
  location            = "Central US"
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet3_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm3" {
  name                            = "vwan-vm3"
  location                        = "Central US"
  resource_group_name             = var.resource_group_name
  size                            = "Standard_B1s"
  admin_username                  = "azureuser"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.nic3.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    IP=$(hostname -I | awk '{print $1}')
    echo "$IP - Welcome to VNet centralus" > /var/www/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOF
  )
}
