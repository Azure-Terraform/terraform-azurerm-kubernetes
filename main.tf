locals {
  cluster_name = "aks-${var.names.resource_group_type}-${var.names.product_name}-${var.names.environment}-${var.names.location}"
}

resource "azurerm_role_assignment" "subnet_network_contributor" {
  count                = (var.use_service_principal ? (var.aks_managed_vnet ? 0 : 1) : 0)
  scope                = var.default_node_pool_subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.aks[0].object_id
}

# Inbound Rules
resource "azurerm_network_security_rule" "inbound_allow_all_vnet" {
  count                       = (var.aks_managed_vnet ? 0 : 1)
  name                        = "AKS_virtual_network"
  priority                    = (local.nsg_rule_priority_start)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.default_node_pool_subnet.resource_group_name
  network_security_group_name = var.default_node_pool_subnet.security_group_name
}

resource "azurerm_network_security_rule" "inbound_allow_all_azure_load_balancer" {
  count                       = (var.aks_managed_vnet ? 0 : 1)
  name                        = "AKS_Azure_LoadBalancer"
  priority                    = (local.nsg_rule_priority_start + 1)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = var.default_node_pool_subnet.resource_group_name
  network_security_group_name = var.default_node_pool_subnet.security_group_name
}

# Outbound Rules
resource "azurerm_network_security_rule" "outbound_allow_azure_cloud" {
  count                       = (var.aks_managed_vnet ? 0 : 1)
  name                        = "AKS_AzureCLoud"
  priority                    = local.nsg_rule_priority_start
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureCloud"
  resource_group_name         = var.default_node_pool_subnet.resource_group_name
  network_security_group_name = var.default_node_pool_subnet.security_group_name
}

#resource "azurerm_network_security_rule" "outbound_allow_azure_cloud_udp_1194" {
#  count                       = (var.aks_managed_vnet ? 0 : 1)
#  name                        = "AKS_control_plane_udp_1194"
#  priority                    = local.nsg_rule_priority_start
#  direction                   = "Outbound"
#  access                      = "Allow"
#  protocol                    = "UDP"
#  source_port_range           = "*"
#  destination_port_range      = "1194"
#  source_address_prefix       = "*"
#  destination_address_prefix  = "AzureCloud"
#  resource_group_name         = var.default_node_pool_subnet.resource_group_name
#  network_security_group_name = var.default_node_pool_subnet.security_group_name
#}
#
#resource "azurerm_network_security_rule" "outbound_allow_azure_cloud_tcp_9000" {
#  count                       = (var.aks_managed_vnet ? 0 : 1)
#  name                        = "AKS_control_plane_tcp_9000"
#  priority                    = (local.nsg_rule_priority_start + 1)
#  direction                   = "Outbound"
#  access                      = "Allow"
#  protocol                    = "TCP"
#  source_port_range           = "*"
#  destination_port_range      = "9000"
#  source_address_prefix       = "*"
#  destination_address_prefix  = "AzureCloud"
#  resource_group_name         = var.default_node_pool_subnet.resource_group_name
#  network_security_group_name = var.default_node_pool_subnet.security_group_name
#}

resource "azurerm_network_security_rule" "outbound_allow_ntp" {
  count                       = (var.aks_managed_vnet ? 0 : 1)
  name                        = "AKS_udp_ntp"
  priority                    = (local.nsg_rule_priority_start + 2)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "UDP"
  source_port_range           = "*"
  destination_port_range      = "123"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.default_node_pool_subnet.resource_group_name
  network_security_group_name = var.default_node_pool_subnet.security_group_name
}

#resource "azurerm_network_security_rule" "outbound_allow_all_tcp_443" {
#  count                       = (var.aks_managed_vnet ? 0 : 1)
#  name                        = "AKS_tcp_ssl"
#  priority                    = (local.nsg_rule_priority_start + 3)
#  direction                   = "Outbound"
#  access                      = "Allow"
#  protocol                    = "TCP"
#  source_port_range           = "*"
#  destination_port_range      = "443"
#  source_address_prefix       = "*"
#  destination_address_prefix  = "Internet"
#  resource_group_name         = var.default_node_pool_subnet.resource_group_name
#  network_security_group_name = var.default_node_pool_subnet.security_group_name
#}
#
#resource "azurerm_network_security_rule" "outbound_allow_azurefiles" {
#  count                       = (var.aks_managed_vnet ? 0 : 1)
#  name                        = "AKS_azure_files"
#  priority                    = (local.nsg_rule_priority_start + 4)
#  direction                   = "Outbound"
#  access                      = "Allow"
#  protocol                    = "TCP"
#  source_port_range           = "*"
#  destination_port_range      = "445"
#  source_address_prefix       = "*"
#  destination_address_prefix  = "AzureCloud"
#  resource_group_name         = var.default_node_pool_subnet.resource_group_name
#  network_security_group_name = var.default_node_pool_subnet.security_group_name
#}

resource "azurerm_network_security_rule" "outbound_allow_all_vnet" {
  count                       = (var.aks_managed_vnet ? 0 : 1)
  name                        = "AKS_virtual_network"
  priority                    = (local.nsg_rule_priority_start + 5)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.default_node_pool_subnet.resource_group_name
  network_security_group_name = var.default_node_pool_subnet.security_group_name
}

resource "azurerm_kubernetes_cluster" "aks" {
  depends_on = [ azurerm_role_assignment.subnet_network_contributor,
                 #azurerm_network_security_rule.outbound_allow_azure_cloud_udp_1194,
                 #azurerm_network_security_rule.outbound_allow_azure_cloud_tcp_9000,
                 azurerm_network_security_rule.outbound_allow_azure_cloud,
                 azurerm_network_security_rule.outbound_allow_ntp,
                 #azurerm_network_security_rule.outbound_allow_all_tcp_443
                ]

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
    vnet_subnet_id      = (var.aks_managed_vnet ? null : var.default_node_pool_subnet.id)

    # disabled due to AKS bug	
    #tags                = var.tags
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
