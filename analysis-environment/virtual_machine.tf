# virtual machine 

variable "prefix" {
  default = "analysis-server"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "public-ip" {
  name                    = "${var.prefix}-pip"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  allocation_method       = "Static"
  sku                     = "Standard"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "analysisserveripconfiguration"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.5"
    public_ip_address_id          = azurerm_public_ip.public-ip.id
  }
}


resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "osstoragedisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.hostname
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = "${data.template_cloudinit_config.config.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
      key_data = file("${var.ssh_public_key_path}")
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
    }
  }
  tags = {
    environment = var.environment
  }
}

# Configure templates for cloud-init
data "template_file" "cloud-init-user-data" {
  template = file("./cloudinit/userdata.yaml")
  vars = {
    admin_username = var.admin_username
  }
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloud-init-user-data.rendered}"
  }
}

output "userdata" {
  value = "\n${data.template_file.cloud-init-user-data.rendered}"
}


# Configure DNS zone
resource "azurerm_dns_zone" "dns-zone" {
  name                = "${lower(var.project_name)}.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_a_record" "a-record" {
  name                = "${var.prefix}"
  zone_name           = azurerm_dns_zone.dns-zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.public-ip.id
}


# Security group allow ssh
resource "azurerm_network_security_group" "security-group" {
  name                = "${var.prefix}-sg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface_security_group_association" "cloudinit" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.security-group.id
}
