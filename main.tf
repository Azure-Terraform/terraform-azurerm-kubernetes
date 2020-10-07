locals {
  cluster_name = "aks-${var.names.resource_group_type}-${var.names.product_name}-${var.names.environment}-${var.names.location}"
}

resource "azurerm_role_assignment" "subnet_network_contributor" {
  count                = (var.use_service_principal ? (var.create_default_node_pool_subnet ? 1 : 0) : 0)
  scope                = var.default_node_pool_subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.aks[0].object_id
}

resource "azurerm_network_security_rule" "outbound_allow_azure_cloud_udp_1194" {
  count                       = (var.create_default_node_pool_subnet ? 0 : 1)
  name                        = "AKS_Control_Plane_UDP_1194"
  priority                    = var.nsg_rule_priority_start
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "UDP"
  source_port_range           = "*"
  destination_port_range      = "1194"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureCloud"
  resource_group_name         = var.default_node_pool_subnet.resource_group_name
  network_security_group_name = var.default_node_pool_subnet.security_group_name
}

resource "azurerm_network_security_rule" "outbound_allow_azure_cloud_tcp_9000" {
  count                       = (var.create_default_node_pool_subnet ? 0 : 1)
  name                        = "AKS_Control_Plane_TCP_9000"
  priority                    = (var.nsg_rule_priority_start + 1)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "9000"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureCloud"
  resource_group_name         = var.default_node_pool_subnet.resource_group_name
  network_security_group_name = var.default_node_pool_subnet.security_group_name
}

resource "azurerm_network_security_rule" "outbound_allow_ntp" {
  count                       = (var.create_default_node_pool_subnet ? 0 : 1)
  name                        = "AKS_NTP"
  priority                    = (var.nsg_rule_priority_start + 2)
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

resource "azurerm_network_security_rule" "outbound_allow_all_tcp_443" {
  count                       = (var.create_default_node_pool_subnet ? 0 : 1)
  name                        = "AKS_SSL"
  priority                    = (var.nsg_rule_priority_start + 3)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.default_node_pool_subnet.resource_group_name
  network_security_group_name = var.default_node_pool_subnet.security_group_name
}

resource "azurerm_kubernetes_cluster" "aks" {
  depends_on = [ azurerm_network_security_rule.outbound_allow_azure_cloud_udp_1194,
                 azurerm_network_security_rule.outbound_allow_azure_cloud_tcp_9000,
                 azurerm_network_security_rule.outbound_allow_ntp,
                 azurerm_network_security_rule.outbound_allow_all_tcp_443 ]

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
    vnet_subnet_id      = (var.create_default_node_pool_subnet ? null : var.default_node_pool_subnet.id)
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
