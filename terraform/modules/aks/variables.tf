variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version used by AKS."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID used by the AKS system node pool."
  type        = string
}

variable "node_vm_size" {
  description = "VM size used by the AKS system node pool."
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the AKS system node pool."
  type        = number
  default     = 1
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID used by AKS monitoring."
  type        = string
}

variable "tags" {
  description = "Tags applied to AKS resources."
  type        = map(string)
  default     = {}
}

variable "tenant_id" {
  description = "Microsoft Entra ID tenant ID used by AKS."
  type        = string
}

variable "node_resource_group_name" {
  description = "Name of the AKS managed node resource group."
  type        = string
}