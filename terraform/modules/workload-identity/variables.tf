variable "name" {
  description = "Name of the User Assigned Managed Identity."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the managed identity."
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL of the AKS cluster."
  type        = string
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace associated with the federated identity."
  type        = string
}

variable "kubernetes_service_account" {
  description = "Kubernetes ServiceAccount associated with the federated identity."
  type        = string
}

variable "key_vault_id" {
  description = "Resource ID of the Key Vault."
  type        = string
}

variable "tags" {
  description = "Tags applied to the managed identity."
  type        = map(string)
  default     = {}
}