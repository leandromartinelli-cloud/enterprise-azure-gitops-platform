output "vnet_id" {
  description = "ID of the Virtual Network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the Virtual Network."
  value       = azurerm_virtual_network.this.name
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet."
  value       = azurerm_subnet.aks.id
}

output "private_endpoint_subnet_id" {
  description = "ID of the subnet reserved for Private Endpoints."
  value       = azurerm_subnet.private_endpoints.id
}

output "ci_runner_subnet_id" {
  description = "Resource ID of the private CI runner subnet."
  value       = azurerm_subnet.ci_runners.id
}