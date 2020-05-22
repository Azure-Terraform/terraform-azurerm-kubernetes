data "helm_repository" "aad_pod_identity" {
  name  = "aad-pod-identity"
  url   = "https://raw.githubusercontent.com/Azure/aad-pod-identity/v${var.aad_pod_identity_version}/charts"
}

resource "helm_release" "aad_pod_identity" {
  depends_on = [azurerm_role_assignment.virtual_machine_contributor, azurerm_role_assignment.managed_identity_operator]
  name       = "aad-pod-identity"
  namespace  = "default"
  repository = data.helm_repository.aad_pod_identity.metadata[0].name
  chart      = "aad-pod-identity"
  version    = var.aad_pod_identity_version

  set {
    name  = "rbac.allowAccessToSecrets"
    value = "false"
  }
}

resource "azurerm_role_assignment" "virtual_machine_contributor" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = data.azuread_service_principal.aks.id
}

resource "azurerm_role_assignment" "managed_identity_operator" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = data.azuread_service_principal.aks.id
}
