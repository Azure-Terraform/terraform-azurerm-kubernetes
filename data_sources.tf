data "azuread_service_principal" "aks" {
  count          = (var.identity_type == "ServicePrincipal" ? 1 : 0)
  application_id = var.service_principal.id
}

locals {
  validate_windows_profile_admin_password = (var.enable_windows_node_pools ? (var.windows_profile_admin_password == "" ? file("ERROR: windows_profile_admin_password cannot be empty") : null) : null)
}