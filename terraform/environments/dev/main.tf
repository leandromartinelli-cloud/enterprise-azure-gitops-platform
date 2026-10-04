data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "platform" {
  name     = local.resource_group_name
  location = var.location

  tags = local.common_tags
}

resource "random_string" "unique" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

module "networking" {
  source = "../../modules/networking"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location

  vnet_name          = local.vnet_name
  vnet_address_space = ["10.20.0.0/16"]

  aks_subnet_name     = local.aks_subnet_name
  aks_subnet_prefixes = ["10.20.0.0/22"]

  private_endpoint_subnet_name     = local.private_endpoint_subnet_name
  private_endpoint_subnet_prefixes = ["10.20.4.0/24"]

  ci_runner_subnet_name     = local.ci_runner_subnet_name
  ci_runner_subnet_prefixes = ["10.20.5.0/24"]

  tags = local.common_tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location

  workspace_name    = local.log_analytics_workspace_name
  retention_in_days = 30

  tags = local.common_tags
}

module "acr" {
  source = "../../modules/acr"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location

  registry_name = local.acr_name
  sku           = "Premium"

  tags = local.common_tags
}

module "acr_private_endpoint" {
  source = "../../modules/acr-private-endpoint"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location

  vnet_name = local.vnet_name
  vnet_id   = module.networking.vnet_id

  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id
  private_endpoint_name      = local.acr_private_endpoint_name

  acr_id = module.acr.registry_id

  tags = local.common_tags
}

module "key_vault" {
  source = "../../modules/key-vault"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location

  key_vault_name = local.key_vault_name

  tags = local.common_tags
}

module "key_vault_private_endpoint" {
  source = "../../modules/key-vault-private-endpoint"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location

  vnet_name = local.vnet_name
  vnet_id   = module.networking.vnet_id

  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id
  private_endpoint_name      = local.key_vault_private_endpoint_name

  key_vault_id = module.key_vault.key_vault_id

  tags = local.common_tags
}

module "aks" {
  source = "../../modules/aks"

  cluster_name        = local.aks_name
  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location

  kubernetes_version = local.aks_kubernetes_version
  tenant_id          = data.azurerm_client_config.current.tenant_id

  subnet_id    = module.networking.aks_subnet_id
  node_vm_size = local.aks_node_vm_size
  node_count   = 1

  log_analytics_workspace_id = module.monitoring.workspace_id

  node_resource_group_name = local.aks_node_resource_group_name

  depends_on = [
    module.monitoring
  ]

  tags = local.common_tags
}

resource "azurerm_role_assignment" "aks_admin" {
  scope                = module.aks.cluster_id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = local.aks_admin_object_id
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.registry_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_identity_object_id
}

module "sample_app_workload_identity" {
  source = "../../modules/workload-identity"

  name                = local.workload_identity_name
  location            = var.location
  resource_group_name = azurerm_resource_group.platform.name

  oidc_issuer_url = module.aks.oidc_issuer_url

  kubernetes_namespace       = "sample-app-dev"
  kubernetes_service_account = "sample-app"

  key_vault_id = module.key_vault.key_vault_id

  tags = local.common_tags
}

module "github_runner" {
  source = "../../modules/github-runner"

  name                = local.github_runner_name
  location            = var.location
  resource_group_name = azurerm_resource_group.platform.name

  subnet_id = module.networking.ci_runner_subnet_id

  vm_size        = "Standard_D2as_v4"
  admin_username = "azureuser"

  ssh_public_key = var.github_runner_ssh_public_key

  tags = local.common_tags
}

resource "azurerm_role_assignment" "github_runner_acr_push" {
  scope                = module.acr.registry_id
  role_definition_name = "AcrPush"
  principal_id         = module.github_runner.principal_id
}

resource "azurerm_role_assignment" "github_runner_aks_cluster_user" {
  scope                = module.aks.cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = module.github_runner.principal_id
}

resource "azurerm_role_assignment" "github_runner_aks_cluster_admin" {
  scope                = module.aks.cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = module.github_runner.principal_id
}
