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

variable "vnet_address_space" {
  description = "Address space assigned to the Virtual Network."
  type        = list(string)
}

variable "aks_subnet_name" {
  description = "Name of the AKS subnet."
  type        = string
}

variable "aks_subnet_prefixes" {
  description = "Address prefixes assigned to the AKS subnet."
  type        = list(string)
}

variable "private_endpoint_subnet_name" {
  description = "Name of the subnet reserved for Private Endpoints."
  type        = string
}

variable "private_endpoint_subnet_prefixes" {
  description = "Address prefixes assigned to the Private Endpoint subnet."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to supported Azure resources."
  type        = map(string)
  default     = {}
}