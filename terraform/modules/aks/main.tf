resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name

  node_resource_group = var.node_resource_group_name

  kubernetes_version = var.kubernetes_version
  dns_prefix         = var.cluster_name

  private_cluster_enabled = true

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    tenant_id          = var.tenant_id
    azure_rbac_enabled = true
  }

  default_node_pool {
    name           = "system"
    node_count     = var.node_count
    vm_size        = var.node_vm_size
    vnet_subnet_id = var.subnet_id

    os_disk_size_gb = 64

    only_critical_addons_enabled = false

    upgrade_settings {
      max_surge                     = "10%"
      drain_timeout_in_minutes      = 0
      node_soak_duration_in_minutes = 0
    }
  }


  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "cilium"

    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"

    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"

    service_cidr   = "10.100.0.0/16"
    dns_service_ip = "10.100.0.10"
  }

  oms_agent {
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    msi_auth_for_monitoring_enabled = true
  }

  tags = var.tags
}