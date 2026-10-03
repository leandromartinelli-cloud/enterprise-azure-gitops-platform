variable "resource_group_name" {
  description = "Name of the Resource Group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network."
  type        = string
}

variable "vnet_id" {
  description = "ID of the Virtual Network."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "ID of the subnet used by Private Endpoints."
  type        = string
}

variable "private_endpoint_name" {
  description = "Name of the ACR Private Endpoint."
  type        = string
}

variable "acr_id" {
  description = "ID of the Azure Container Registry."
  type        = string
}

variable "tags" {
  description = "Tags applied to supported resources."
  type        = map(string)
  default     = {}
}