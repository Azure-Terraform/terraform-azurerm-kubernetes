data "azurerm_client_config" "current" {
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azuread_service_principal" "aks" {
  display_name = var.service_principal_name
}