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

resource "null_resource" "run_kured" {
  count = var.enable_kured ? 1 : 0
  depends_on = [azurerm_kubernetes_cluster.aks]
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<HERE
    # Authenticate to cluster
    az aks get-credentials --resource-group ${var.resource_group_name} --name ${local.cluster_name}
    echo "az aks installed. Output of kubectl get nodes :"
    kubectl get nodes
    # Get Namespace
    GREPPED_NAMESPACE=`kubectl get namespaces | grep ${var.kured_namespace}`
    if [[ -z $GREPPED_NAMESPACE ]]; then
      # If namespace does not exist, create it
      kubectl create namespace ${var.kured_namespace}
      echo "Created namespace"
    fi
    helm repo add kured https://weaveworks.github.io/kured
    helm repo update
    helm install rebooter kured/kured --version ${var.kured_version} --namespace ${var.kured_namespace} --set nodeSelector."beta\.kubernetes\.io/os"=linux
HERE
  }
}
