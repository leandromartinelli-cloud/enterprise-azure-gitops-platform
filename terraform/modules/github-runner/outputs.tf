output "vm_id" {
  description = "Resource ID of the GitHub Actions runner VM."
  value       = azurerm_linux_virtual_machine.this.id
}

output "vm_name" {
  description = "Name of the GitHub Actions runner VM."
  value       = azurerm_linux_virtual_machine.this.name
}

output "private_ip_address" {
  description = "Private IP address of the GitHub Actions runner VM."
  value       = azurerm_network_interface.this.private_ip_address
}

output "principal_id" {
  description = "Principal ID of the GitHub runner VM system-assigned managed identity."
  value       = azurerm_linux_virtual_machine.this.identity[0].principal_id
}