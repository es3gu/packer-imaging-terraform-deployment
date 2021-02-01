variable "version" {
    type = string
}

variable "subscription" {
    type = string
    description = "Subsription in which the resource group is created within."
    default = ""
}

variable "image" {
    description = "CIS image reference"
    type = map(string)
    default = {
      publisher = "center-for-internet-security-inc"
      offer = "cis-ubuntu-linux-2004-l1"
      sku = "cis-ubuntu2004-l1"
    }
}