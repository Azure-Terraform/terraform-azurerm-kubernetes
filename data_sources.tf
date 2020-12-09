data "azuread_service_principal" "aks" {
  count          = (var.use_service_principal ? 1 : 0)
  application_id = var.service_principal_id
}

data "azurerm_public_ip" "effective_outbound_ips" {
  for_each            = azurerm_kubernetes_cluster.aks.network_profile[0].load_balancer_profile[0].effective_outbound_ips
  name                = split("/", each.value)[(length(split("/", each.value))-1)]
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
}

locals {
  validate_windows_profile_admin_password = (var.enable_windows_node_pools ? (var.windows_profile_admin_password == "" ? file("ERROR: windows_profile_admin_password cannot be empty") : null) : null)
}
