provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

data "helm_repository" "aad_pod_identity" {
  count = (var.enable_aad_pod_identity ? 1 : 0)
  name  = "aad-pod-identity"
  url   = "https://raw.githubusercontent.com/Azure/aad-pod-identity/v${var.aad_pod_identity_version}/charts"
}

resource "helm_release" "aad_pod_identity" {
  depends_on = [azurerm_role_assignment.virtual_machine_contributor, azurerm_role_assignment.managed_identity_operator]
  count      = (var.enable_aad_pod_identity ? 1 : 0)
  name       = "aad-pod-identity"
  namespace  = "default"
  repository = data.helm_repository.aad_pod_identity.0.metadata[0].name
  chart      = "aad-pod-identity"
  version    = var.aad_pod_identity_version

  set {
    name  = "rbac.allowAccessToSecrets"
    value = "false"
  }
}

resource "azurerm_role_assignment" "virtual_machine_contributor" {
  count                = (var.enable_aad_pod_identity ? 1 : 0)
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = data.azuread_service_principal.aks.id
}

resource "azurerm_role_assignment" "managed_identity_operator" {
  count                = (var.enable_aad_pod_identity ? 1 : 0)
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = data.azuread_service_principal.aks.id
}