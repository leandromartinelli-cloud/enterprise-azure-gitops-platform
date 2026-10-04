variable "location" {
  description = "Azure region used by the platform."
  type        = string
  default     = "brazilsouth"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project identifier used for naming and tagging."
  type        = string
  default     = "enterprise-gitops"
}

variable "owner" {
  description = "Owner responsible for the Azure resources."
  type        = string
  default     = "leandro-martinelli"
}

variable "cost_center" {
  description = "Cost center used for FinOps resource allocation."
  type        = string
  default     = "lab"
}

variable "github_runner_ssh_public_key" {
  description = "SSH public key used by the GitHub Actions runner VM."
  type        = string
}