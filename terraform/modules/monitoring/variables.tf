variable "resource_group_name" {
  description = "Name of the Resource Group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "workspace_name" {
  description = "Name of the Log Analytics Workspace."
  type        = string
}

variable "retention_in_days" {
  description = "Log Analytics retention period in days."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to the Log Analytics Workspace."
  type        = map(string)
  default     = {}
}