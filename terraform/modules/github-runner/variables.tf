variable "name" {
  description = "Name of the GitHub Actions runner virtual machine."
  type        = string
}

variable "location" {
  description = "Azure region where the runner is deployed."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the runner."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID used by the GitHub Actions runner."
  type        = string
}

variable "vm_size" {
  description = "Azure VM size for the GitHub Actions runner."
  type        = string
  default     = "Standard_D2as_v4"
}

variable "admin_username" {
  description = "Administrator username for the runner VM."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key used by the runner VM."
  type        = string
}

variable "tags" {
  description = "Tags applied to runner resources."
  type        = map(string)
  default     = {}
}
