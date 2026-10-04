output "identity_id" {
  description = "Resource ID of the User Assigned Managed Identity."
  value       = azurerm_user_assigned_identity.this.id
}

output "client_id" {
  description = "Client ID of the User Assigned Managed Identity."
  value       = azurerm_user_assigned_identity.this.client_id
}

output "principal_id" {
  description = "Principal ID of the User Assigned Managed Identity."
  value       = azurerm_user_assigned_identity.this.principal_id
}