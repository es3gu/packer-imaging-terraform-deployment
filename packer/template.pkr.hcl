source "azure-arm" "nginx" {
    use_azure_cli_auth = "true"

    image_publisher = var.image["publisher"]
    image_offer     = var.image["offer"]
    image_sku       = var.image["sku"]

    plan_info {
      plan_name      = var.image["sku"]
      plan_product   = var.image["offer"]
      plan_publisher = var.image["publisher"]
    }

    managed_image_resource_group_name = "sig-rg"
    managed_image_name = "nginx-${var.version}"
    location = "UKSouth"
    vm_size = "Standard_B2s"
    os_type = "Linux"

    shared_image_gallery_destination {
      subscription = var.subscription
      resource_group = "sig-rg"
      gallery_name = "sig"
      image_name = "nginx"
      image_version = var.version
      replication_regions = ["UKWest", "UKSouth"]
    }
}

build {
    sources = [
        "source.azure-arm.nginx"
    ]

    provisioner "ansible" {
        playbook_file = "./ansible/nginx.yml"
        ansible_env_vars = [ "ANSIBLE_ROLES_PATH=~/.ansible/roles" ]
    }
}