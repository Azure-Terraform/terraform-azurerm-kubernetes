resource "azurerm_kubernetes_cluster" "aks" {
  name                 = "aks-${var.names.market}-${var.names.environment}-${var.names.location}-${var.names.product_name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  dns_prefix           = "${var.names.market}${var.names.environment}${var.names.location}"
  tags                 = var.tags

  kubernetes_version = var.kubernetes_version
  
  network_profile {
    network_plugin       = "kubenet"
  }

  default_node_pool {
    name                = var.default_node_pool_name
    vm_size             = var.default_node_pool_vm_size
    enable_auto_scaling = var.default_node_pool_enable_auto_scaling
    node_count          = (var.default_node_pool_enable_auto_scaling ? null :var.default_node_pool_node_count)
    min_count           = (var.default_node_pool_enable_auto_scaling ? var.default_node_pool_node_min_count : null)
    max_count           = (var.default_node_pool_enable_auto_scaling ? var.default_node_pool_node_max_count : null)
    availability_zones  = var.default_node_pool_availability_zones
    # disabled due to AKS bug	
    #tags                = var.tags
  }

  addon_profile {
    kube_dashboard {
      enabled = var.enable_kube_dashboard
    }
  }

  service_principal {
    client_id     = var.service_principal_id
    client_secret = var.service_principal_secret
  }

}
