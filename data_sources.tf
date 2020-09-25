data "azuread_service_principal" "aks" {
  count          = (var.use_service_principal ? 1 : 0)
  application_id = var.service_principal_id
}
