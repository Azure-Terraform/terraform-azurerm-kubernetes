data "azuread_service_principal" "aks" {
  count          = (var.identity_type == "ServicePrincipal" ? 1 : 0)
  application_id = var.service_principal_id
}

data "azurerm_user_assigned_identity" "aks" {
  count               = (var.identity_type == "UserAssigned" ? (var.user_assigned_identity == null ? 0 : 1) : 0)
  name                = var.user_assigned_identity.name
  resource_group_name = var.user_assigned_identity.resource_group
}

locals {
  validate_windows_profile_admin_password = (var.enable_windows_node_pools ? (var.windows_profile_admin_password == "" ? file("ERROR: windows_profile_admin_password cannot be empty") : null) : null)
}
