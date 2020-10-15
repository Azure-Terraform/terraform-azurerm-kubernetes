data "azuread_service_principal" "aks" {
  count          = (var.use_service_principal ? 1 : 0)
  application_id = var.service_principal_id
}

locals {
  validate_subnet_sp = (var.aks_managed_vnet? null : (var.use_service_principal ? null : file("ERROR: must use service principal if setting default_node_pool_vnet_subnet_id")))


  validate_nsg_rule_priority_start = (var.aks_managed_vnet ? null : (tonumber(split("-", var.nsg_rule_priority_range)[0]) >= 100 ? null : file("ERROR: nsg_rule_priority_range must be between 100-4096")))
  validate_nsg_rule_priority_end = (var.aks_managed_vnet ? null : (tonumber(split("-", var.nsg_rule_priority_range)[1]) <= 4096 ? null : file("ERROR: nsg_rule_priority_range must be between 100-4096")))

  nsg_rule_priority_start = tonumber(split("-", var.nsg_rule_priority_range)[0])

  validate_windows_profile_admin_password = (var.enable_windows_node_pools ? (var.windows_profile_admin_password == "" ? file("ERROR: windows_profile_admin_password cannot be empty") : null) : null)
}
