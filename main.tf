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
  for_each             = (var.identity_type != "SystemAssigned" && var.configure_network_role ? var.custom_route_table_ids : {})

  scope                = each.value
  role_definition_name = "Network Contributor"
  principal_id         = (var.identity_type == "ServicePrincipal" ? data.azuread_service_principal.aks.0.id :
                           (var.user_assigned_identity == null ? azurerm_user_assigned_identity.aks.0.principal_id :
                            var.user_assigned_identity.id))
}

module "subnet_config" {
  source = "./subnet_config"

  for_each = (var.aks_managed_vnet ? {} : var.node_pool_subnets)

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
    name                = var.default_node_pool_name
    vm_size             = var.default_node_pool_vm_size
    enable_auto_scaling = var.default_node_pool_enable_auto_scaling
    node_count          = (var.default_node_pool_enable_auto_scaling ? null : var.default_node_pool_node_count)
    min_count           = (var.default_node_pool_enable_auto_scaling ? var.default_node_pool_node_min_count : null)
    max_count           = (var.default_node_pool_enable_auto_scaling ? var.default_node_pool_node_max_count : null)
    availability_zones  = var.default_node_pool_availability_zones
    vnet_subnet_id      = (var.aks_managed_vnet ? null : var.node_pool_subnets[var.default_node_pool_subnet].id)
    tags                = var.tags
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
      user_assigned_identity_id = (var.identity_type == "SystemAssigned" ? null :
                                    (var.user_assigned_identity != null ? 
                                    var.user_assigned_identity.id : 
                                    azurerm_user_assigned_identity.aks.0.id))
    }
  }

  dynamic "service_principal" {
    for_each = (var.identity_type == "ServicePrincipal" ? [1] : [])
    content {
      client_id     = var.service_principal.client_id
      client_secret = var.service_principal.client_secret
    }
  }

  role_based_access_control {
    enabled = ((length(var.rbac_admin_object_ids) > 0) ||
                (var.rbac_ad_app_info != null)) ? true : false

    dynamic "azure_active_directory" {
      for_each = (length(var.rbac_admin_object_ids) > 0 ? ["managed"] : [])
      content {
        managed                = true
        admin_group_object_ids = values(var.rbac_admin_object_ids)
      }
    }

    dynamic "azure_active_directory" {
      for_each          = (var.rbac_ad_app_info != null ? ["unmanaged"] : [])
      content {
        managed           = false
        client_app_id     = var.rbac_ad_app_info.client_app_id
        server_app_id     = var.rbac_ad_app_info.server_app_id
        server_app_secret = var.rbac_ad_app_info.server_app_secret
      }
    }
  }
}

resource "azurerm_role_assignment" "rbac_admin" {
  for_each             = var.rbac_admin_object_ids 
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "acr_pull" {
  for_each                         = var.acr_pull_access
  scope                            = each.value
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true
}