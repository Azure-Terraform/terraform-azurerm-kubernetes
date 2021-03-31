resource "azurerm_user_assigned_identity" "aks" {
  count = (var.identity_type == "UserAssigned" && var.user_assigned_identity == null ? 1 : 0)

  resource_group_name = var.resource_group_name
  location            = var.location
  name                = "uai-${local.cluster_name}"
}

resource "azurerm_role_assignment" "route_table_network_contributor" {
  for_each             = ((var.identity_type == "UserAssigned" && var.configure_network_role) ? var.custom_route_table_ids : {})

  scope                = each.value
  role_definition_name = "Network Contributor"
  principal_id         = (var.user_assigned_identity == null ? azurerm_user_assigned_identity.aks.0.principal_id :
                          var.user_assigned_identity.principal_id)
}

module "subnet_config" {
  source = "./subnet_config"

  for_each = var.node_pool_subnets

  subnet_info  = each.value
  principal_id = local.aks_identity_id

  configure_network_role  = var.configure_network_role
  configure_nsg_rules     = var.configure_subnet_nsg_rules
  nsg_rule_priority_start = var.subnet_nsg_rule_priority_start
}

resource "azurerm_kubernetes_cluster" "aks" {
  depends_on          = [azurerm_role_assignment.route_table_network_contributor]

  name                = local.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  kubernetes_version  = var.kubernetes_version
  node_resource_group = local.node_resource_group
  dns_prefix          = local.dns_prefix

  network_profile {
    network_plugin = var.network_plugin
  }

  default_node_pool {
    name                         = var.default_node_pool
    vm_size                      = local.node_pools[var.default_node_pool].vm_size
    os_disk_size_gb              = local.node_pools[var.default_node_pool].os_disk_size_gb
    os_disk_type                 = local.node_pools[var.default_node_pool].os_disk_type
    availability_zones           = local.node_pools[var.default_node_pool].availability_zones
    enable_auto_scaling          = local.node_pools[var.default_node_pool].enable_auto_scaling
    node_count                   = (local.node_pools[var.default_node_pool].enable_auto_scaling ? null : local.node_pools[var.default_node_pool].node_count)
    min_count                    = (local.node_pools[var.default_node_pool].enable_auto_scaling ? local.node_pools[var.default_node_pool].min_count : null)
    max_count                    = (local.node_pools[var.default_node_pool].enable_auto_scaling ? local.node_pools[var.default_node_pool].max_count : null)
    enable_host_encryption       = local.node_pools[var.default_node_pool].enable_host_encryption
    enable_node_public_ip        = local.node_pools[var.default_node_pool].enable_node_public_ip
    type                         = local.node_pools[var.default_node_pool].type
    only_critical_addons_enabled = local.node_pools[var.default_node_pool].only_critical_addons_enabled
    orchestrator_version         = local.node_pools[var.default_node_pool].orchestrator_version
    max_pods                     = local.node_pools[var.default_node_pool].max_pods
    node_labels                  = local.node_pools[var.default_node_pool].node_labels
    tags                         = local.node_pools[var.default_node_pool].tags
    vnet_subnet_id               = (local.node_pools[var.default_node_pool].subnet != null ?
                                    var.node_pool_subnets[local.node_pools[var.default_node_pool].subnet].id : null)

    upgrade_settings {
      max_surge = local.node_pools[var.default_node_pool].max_surge
    }
  }

  addon_profile {
    kube_dashboard {
      enabled = var.enable_kube_dashboard
    }
  }

  dynamic "windows_profile" {
    for_each = local.windows_nodes ? [1] : []
    content {
      admin_username = var.windows_profile.admin_username
      admin_password = var.windows_profile.admin_password
    }
  }

  identity {
    type                      = var.identity_type
    user_assigned_identity_id = (var.identity_type == "SystemAssigned" ? null :
                                (var.user_assigned_identity != null ? 
                                 var.user_assigned_identity.id : 
                                 azurerm_user_assigned_identity.aks.0.id))
  }

  role_based_access_control {
    enabled = var.rbac.enabled
    dynamic "azure_active_directory" {
      for_each = (var.rbac.ad_integration ? [1] : [])
      content {
        managed                = true
        admin_group_object_ids = values(var.rbac_admin_object_ids)
      }
    }
  }
}

resource "azurerm_role_assignment" "rbac_admin" {
  for_each             = (var.rbac.ad_integration ? var.rbac_admin_object_ids : {}) 
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = each.value
}

resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each = local.additional_node_pools

  kubernetes_cluster_id        = azurerm_kubernetes_cluster.aks.id

  name                         = each.key
  vm_size                      = each.value.vm_size
  os_disk_size_gb              = each.value.os_disk_size_gb
  os_disk_type                 = each.value.os_disk_type
  availability_zones           = each.value.availability_zones
  enable_auto_scaling          = each.value.enable_auto_scaling
  node_count                   = (each.value.enable_auto_scaling ? null : each.value.node_count)
  min_count                    = (each.value.enable_auto_scaling ? each.value.min_count : null)
  max_count                    = (each.value.enable_auto_scaling ? each.value.max_count : null)
  os_type                      = each.value.os_type
  enable_host_encryption       = each.value.enable_host_encryption
  enable_node_public_ip        = each.value.enable_node_public_ip
  max_pods                     = each.value.max_pods
  node_labels                  = each.value.node_labels
  orchestrator_version         = each.value.orchestrator_version
  tags                         = each.value.tags
  vnet_subnet_id               = (each.value.subnet != null ?
                                  var.node_pool_subnets[each.value.subnet].id : null)

  node_taints                  = each.value.node_taints
  eviction_policy              = each.value.eviction_policy
  proximity_placement_group_id = each.value.proximity_placement_group_id
  spot_max_price               = each.value.spot_max_price
  priority                     = each.value.priority
  mode                         = each.value.mode

  upgrade_settings {
    max_surge = each.value.max_surge
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  for_each                         = var.acr_pull_access
  scope                            = each.value
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true
}
