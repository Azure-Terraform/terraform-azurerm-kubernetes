locals {
  cluster_name = "aks-${var.names.resource_group_type}-${var.names.product_name}-${var.names.environment}-${var.names.location}"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                 = local.cluster_name
  location             = var.location
  resource_group_name  = var.resource_group_name
  dns_prefix           = "${var.names.product_name}-${var.names.environment}-${var.names.location}"
  tags                 = var.tags

  kubernetes_version = var.kubernetes_version
  
  network_profile {
    network_plugin       = var.network_plugin
  }

  default_node_pool {
    name                = var.default_node_pool_name
    vm_size             = var.default_node_pool_vm_size
    enable_auto_scaling = var.default_node_pool_enable_auto_scaling
    node_count          = (var.default_node_pool_enable_auto_scaling ? null : var.default_node_pool_node_count)
    min_count           = (var.default_node_pool_enable_auto_scaling ? var.default_node_pool_node_min_count : null)
    max_count           = (var.default_node_pool_enable_auto_scaling ? var.default_node_pool_node_max_count : null)
    availability_zones  = var.default_node_pool_availability_zones
    vnet_subnet_id      = (var.default_node_pool_vnet_subnet_id != "" ? var.default_node_pool_vnet_subnet_id : null)	
    # disabled due to AKS bug	
    #tags                = var.tags
  }

  addon_profile {
    kube_dashboard {
      enabled = var.enable_kube_dashboard
    }
  }

  dynamic "identity" {
    for_each = var.use_service_principal ? [] : [1]
    content {
      type = "SystemAssigned"
    }
  }

  dynamic "service_principal" {
    for_each = var.use_service_principal ? [1] : []
    content {
      client_id     = var.service_principal_id
      client_secret = var.service_principal_secret
    }
  }
}
