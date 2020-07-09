data "azuread_service_principal" "aks" {
  count        = (var.use_service_principal ? 1 : 0)
  display_name = var.service_principal_name
}
