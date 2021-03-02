data "azuread_service_principal" "aks" {
  count          = (var.identity_type == "ServicePrincipal" ? 1 : 0)
  application_id = var.service_principal.id
}

locals {
  validate_windows_profile_admin_password = (var.enable_windows_node_pools ? (var.windows_profile_admin_password == "" ? file("ERROR: windows_profile_admin_password cannot be empty") : null) : null)

  validate_rbac = (((length(var.rbac_admin_object_ids) > 0) && (var.rbac_ad_app_info != null)) ?
                     file("ERROR - variables rbac_admin_object_ids and rbac_ad_app_info cannot both be used") : null)
}