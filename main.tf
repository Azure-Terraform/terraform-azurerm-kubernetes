locals {
  cluster_name = "aks-${var.names.resource_group_type}-${var.names.product_name}-${var.names.environment}-${var.names.location}"

  aks_identity_id = (var.identity_type == "ServicePrincipal" ? data.azuread_service_principal.aks.0.id :
                     (var.identity_type == "SystemAssigned" ? azurerm_kubernetes_cluster.aks.identity.0.principal_id :
                      (var.user_assigned_identity == null ? azurerm_user_assigned_identity.aks.0.principal_id :
                       var.user_assigned_identity.id)))
}

resource "azurerm_user_assigned_identity" "aks" {
  count = (var.identity_type == "UserAssigned" && var.user_assigned_identity == null ? 1 : 0)

  resource_group_name = var.resource_group_name
  location            = var.location
  name                = "uai-${local.cluster_name}"
}

resource "azurerm_role_assignment" "route_table_network_contributor" {
  for_each             = (var.identity_type != "SystemAssigned" ? local.custom_route_table_ids : [])

  scope                = each.value
  role_definition_name = "Network Contributor"
  principal_id         = (var.identity_type == "ServicePrincipal" ? data.azuread_service_principal.aks.0.id :
                           (var.user_assigned_identity == null ? azurerm_user_assigned_identity.aks.0.principal_id :
                            var.user_assigned_identity.id))
}

module "subnet_config" {
  source = "./subnet_config"

  for_each = local.subnet_info

  subnet_info  = each.value
  principal_id = local.aks_identity_id

  configure_network_role  = var.configure_network_role
  configure_nsg_rules     = var.configure_subnet_nsg_rules
  nsg_rule_priority_start = var.subnet_nsg_rule_priority_start
}

resource "azurerm_kubernetes_cluster" "aks" {
  depends_on          = [azurerm_role_assignment.route_table_network_contributor]
  #lifecycle {
  #  ignore_changes = [(local.node_pools[var.default_node_pool].enable_auto_scaling ? "node_count" : "")] 
  #}

  name                = local.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.names.product_name}-${var.names.environment}-${var.names.location}"
  tags                = var.tags

  kubernetes_version = var.kubernetes_version

  network_profile {
    network_plugin = var.network_plugin
  }

  default_node_pool {
    name                         = local.node_pools[var.default_node_pool].name
    vm_size                      = local.node_pools[var.default_node_pool].vm_size
    availability_zones           = local.node_pools[var.default_node_pool].availability_zones
    node_count                   = local.node_pools[var.default_node_pool].node_count
    enable_auto_scaling          = local.node_pools[var.default_node_pool].enable_auto_scaling
    min_count                    = local.node_pools[var.default_node_pool].min_count
    max_count                    = local.node_pools[var.default_node_pool].max_count
    enable_host_encryption       = local.node_pools[var.default_node_pool].enable_host_encryption
    vnet_subnet_id               = local.node_pools[var.default_node_pool].subnet_id
    tags                         = local.node_pools[var.default_node_pool].tags
    enable_node_public_ip        = local.node_pools[var.default_node_pool].enable_node_public_ip
    max_pods                     = local.node_pools[var.default_node_pool].max_pods
    node_labels                  = local.node_pools[var.default_node_pool].node_labels
    only_critical_addons_enabled = local.node_pools[var.default_node_pool].only_critical_addons_enabled
    orchestrator_version         = local.node_pools[var.default_node_pool].orchestrator_version
    os_disk_size_gb              = local.node_pools[var.default_node_pool].os_disk_size_gb
    os_disk_type                 = local.node_pools[var.default_node_pool].os_disk_type
    upgrade_settings {
      max_surge = local.node_pools[var.default_node_pool].max_surge
    }
  }

  #dynamic "upgrade_settings" {
  #  for_each = (each.value.max_surge == null ? [] : [1])
  #  content {
  #    max_surge = each.value.max_surge
  #  }
  #}

  addon_profile {
    kube_dashboard {
      enabled = var.enable_kube_dashboard
    }
  }

  dynamic "windows_profile" {
    for_each = var.enable_windows_node_pools ? [1] : []
    content {
      admin_username = var.windows_profile_admin_username
      admin_password = var.windows_profile_admin_password
    }
  }

  dynamic "identity" {
    for_each = (var.identity_type == "ServicePrincipal" ? [] : [1])
    content {
      type                      = var.identity_type
      user_assigned_identity_id = (var.user_assigned_identity != null ? 
                                   var.user_assigned_identity.id : 
                                   azurerm_user_assigned_identity.aks.0.id)
    }
  }

  dynamic "service_principal" {
    for_each = (var.identity_type == "ServicePrincipal" ? [1] : [])
    content {
      client_id     = var.service_principal.client_id
      client_secret = var.service_principal.client_secret
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "example" {
  for_each = local.additional_node_pools
  #lifecycle {
  #  ignore_changes = [(each.value.enable_auto_scaling ? "node_count" : "")] 
  #}

  name                         = each.value.name
  kubernetes_cluster_id        = azurerm_kubernetes_cluster.aks.id
  vm_size                      = each.value.vm_size
  availability_zones           = each.value.availability_zones
  enable_auto_scaling          = each.value.enable_auto_scaling
  enable_host_encryption       = each.value.enable_host_encryption
  enable_node_public_ip        = each.value.enable_node_public_ip
  max_pods                     = each.value.max_pods
  mode                         = each.value.mode
  node_labels                  = each.value.node_labels
  node_taints                  = each.value.node_taints
  orchestrator_version         = each.value.orchestrator_version
  os_disk_size_gb              = each.value.os_disk_size_gb
  os_type                      = each.value.os_type
  priority                     = each.value.priority
  proximity_placement_group_id = each.value.proximity_placement_group_id
  spot_max_price               = each.value.spot_max_price
  tags                         = each.value.tags
  vnet_subnet_id               = each.value.subnet_id

  node_count                   = each.value.node_count

  upgrade_settings {
    max_surge = each.value.max_surge
  }

  #dynamic "upgrade_settings" {
  #  for_each = (each.value.max_surge == null ? [] : [1])
  #  content {
  #    max_surge = each.value.max_surge
  #  }
  #}

}