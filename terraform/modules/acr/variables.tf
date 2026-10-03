variable "resource_group_name" {
  description = "Name of the Resource Group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "registry_name" {
  description = "Globally unique Azure Container Registry name."
  type        = string
}

variable "sku" {
  description = "Azure Container Registry SKU."
  type        = string
  default     = "Premium"
}

variable "tags" {
  description = "Tags applied to the Azure Container Registry."
  type        = map(string)
  default     = {}
}