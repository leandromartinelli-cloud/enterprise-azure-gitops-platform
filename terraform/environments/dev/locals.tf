locals {
  resource_group_name          = "rg-${var.project_name}-${var.environment}-${var.location}"
  vnet_name                    = "vnet-${var.project_name}-${var.environment}-${var.location}"
  aks_subnet_name              = "snet-aks"
  private_endpoint_subnet_name = "snet-private-endpoints"
  ci_runner_subnet_name        = "snet-ci-runners"
  log_analytics_workspace_name = "log-${var.project_name}-${var.environment}-${var.location}"

  acr_name                        = "acrentgitopsdev${random_string.unique.result}"
  key_vault_name                  = "kv-entgitops-dev-${random_string.unique.result}"
  acr_private_endpoint_name       = "pep-${local.acr_name}"
  key_vault_private_endpoint_name = "pep-${local.key_vault_name}"
  workload_identity_name          = "id-sample-app-${var.environment}-${var.location}"

  aks_name                     = "aks-${var.project_name}-${var.environment}-${var.location}"
  aks_admin_object_id          = "e8e0f801-82be-406d-b95f-01061783ce0e"
  aks_node_resource_group_name = "rg-aks-nodes-gitops-dev-brazilsouth"

  aks_kubernetes_version = "1.36.4"
  aks_node_vm_size       = "Standard_D2as_v4"

  common_tags = {
    Environment = var.environment
    Application = var.project_name
    Owner       = var.owner
    ManagedBy   = "terraform"
    CostCenter  = var.cost_center
    Project     = "enterprise-azure-gitops-platform"
  }
}