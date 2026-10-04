resource "azurerm_user_assigned_identity" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_federated_identity_credential" "this" {
  name                      = "${var.name}-federated"
  user_assigned_identity_id = azurerm_user_assigned_identity.this.id

  audience = [
    "api://AzureADTokenExchange"
  ]

  issuer  = var.oidc_issuer_url
  subject = "system:serviceaccount:${var.kubernetes_namespace}:${var.kubernetes_service_account}"
}

resource "azurerm_role_assignment" "key_vault_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}