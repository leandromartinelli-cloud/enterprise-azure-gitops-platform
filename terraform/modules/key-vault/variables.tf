variable "resource_group_name" {
  description = "Name of the Resource Group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "key_vault_name" {
  description = "Globally unique Azure Key Vault name."
  type        = string
}

variable "tags" {
  description = "Tags applied to the Azure Key Vault."
  type        = map(string)
  default     = {}
}