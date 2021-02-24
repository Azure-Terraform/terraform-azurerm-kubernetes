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
    name                   = local.node_pools[var.default_node_pool].name
    vm_size                = local.node_pools[var.default_node_pool].vm_size
    availability_zones     = local.node_pools[var.default_node_pool].availability_zones
    node_count             = local.node_pools[var.default_node_pool].node_count
    enable_auto_scaling    = local.node_pools[var.default_node_pool].enable_auto_scaling
    min_count              = local.node_pools[var.default_node_pool].min_count
    max_count              = local.node_pools[var.default_node_pool].max_count
    enable_host_encryption = local.node_pools[var.default_node_pool].enable_host_encryption
    vnet_subnet_id         = local.node_pools[var.default_node_pool].subnet_id
    tags                   = local.node_pools[var.default_node_pool].tags
  }

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
