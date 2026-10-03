output "private_endpoint_id" {
  description = "ID of the Key Vault Private Endpoint."
  value       = azurerm_private_endpoint.key_vault.id
}

output "private_dns_zone_id" {
  description = "ID of the Key Vault Private DNS Zone."
  value       = azurerm_private_dns_zone.key_vault.id
}