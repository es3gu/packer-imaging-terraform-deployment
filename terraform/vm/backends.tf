provider "azurerm" {
    version = "~> 2.0"
    subscription_id = ""
    features {}
}

terraform {
  backend "azurerm" {
    storage_account_name = ""
    resource_group_name  = ""
    container_name       = ""
    key                  = ""
  }
}