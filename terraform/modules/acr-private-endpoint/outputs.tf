output "private_endpoint_id" {
  description = "ID of the ACR Private Endpoint."
  value       = azurerm_private_endpoint.acr.id
}

output "private_dns_zone_id" {
  description = "ID of the ACR Private DNS Zone."
  value       = azurerm_private_dns_zone.acr.id
}