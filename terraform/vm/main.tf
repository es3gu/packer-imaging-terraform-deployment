data "terraform_remote_state" "sig" {
  backend = "azurerm"
  config = {
    storage_account_name = ""
    container_name       = ""
    key                  = ""
    access_key           = ""
  }
}

data "azurerm_shared_image_version" "nginx" {
    name                = "latest"
    gallery_name        = data.terraform_remote_state.sig.outputs.nginx.gallery_name
    resource_group_name = data.terraform_remote_state.sig.outputs.nginx.resource_group_name
    image_name          = data.terraform_remote_state.sig.outputs.nginx.name
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet01"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "vnet_subnet" {
  name                 = "subnet01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.vnet_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "pip" {
  name                = "nginx-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "nginx-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name = "nginx-nic"
    public_ip_address_id          = azurerm_public_ip.pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.vnet_subnet.id
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "nginx-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  vm_size               = "Standard_B2s"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
      id      = data.azurerm_shared_image_version.nginx.id
      version = "latest"
  }

  plan {
    publisher = "center-for-internet-security-inc"
    product   = "cis-ubuntu-linux-2004-l1"
    name      = "cis-ubuntu2004-l1"
  }

  storage_os_disk {
    name              = "nginx-vm-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "nginx-vm"
    admin_username = "adminuser"
    admin_password = "ItsMePassword!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}