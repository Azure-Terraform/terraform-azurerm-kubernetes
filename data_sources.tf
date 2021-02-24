data "azuread_service_principal" "aks" {
  count          = (var.identity_type == "ServicePrincipal" ? 1 : 0)
  application_id = var.service_principal.id
}