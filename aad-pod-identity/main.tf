data "azurerm_resource_group" "node_rg" {
  name = var.node_resource_group_name
}

#data "azurerm_resource_group" "rg" {
#  name = var.resource_group_name
#}

resource "helm_release" "aad_pod_identity" {
  depends_on = [azurerm_role_assignment.k8s_virtual_machine_contributor, azurerm_role_assignment.k8s_managed_identity_operator,azurerm_role_assignment.additional_managed_identity_operator]
  name       = "aad-pod-identity"
  namespace  = "default"
  repository = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
  chart      = "aad-pod-identity"
  version    = var.helm_chart_version

  set {
    name  = "rbac.allowAccessToSecrets"
    value = "false"
  }
}

resource "azurerm_role_assignment" "k8s_virtual_machine_contributor" {
  scope                = data.azurerm_resource_group.node_rg.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = var.principal_id
}

resource "azurerm_role_assignment" "k8s_managed_identity_operator" {
  scope                = data.azurerm_resource_group.node_rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.principal_id
}

resource "azurerm_role_assignment" "additional_managed_identity_operator" {
  count                = length(var.additional_scopes)
  scope                = var.additional_scopes[count.index]
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.principal_id
}
