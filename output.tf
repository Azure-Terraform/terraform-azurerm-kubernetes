output "id" {
  depends_on   = [helm_release.aad_pod_identity]
  description = "kubernetes managed cluster id"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "fqdn" {
  depends_on   = [helm_release.aad_pod_identity]
  description = "kubernetes managed cluster fqdn"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "node_resource_group" {
  depends_on   = [helm_release.aad_pod_identity]
  description  = "auto-generated resource group which contains the resources for this managed kubernetes cluster"
  value        = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "kube_config_raw" {
  depends_on   = [helm_release.aad_pod_identity]
  description  = "raw kubernetes config to be used by kubectl and other compatible tools"
  value        = azurerm_kubernetes_cluster.aks.kube_config_raw
}

output "host" {
  depends_on   = [helm_release.aad_pod_identity]
  description  = "kubernetes host"
  value        = azurerm_kubernetes_cluster.aks.kube_config.0.host
}

output "username" {
  depends_on   = [helm_release.aad_pod_identity]
  description  = "kubernetes username"
  value        = azurerm_kubernetes_cluster.aks.kube_config.0.username
}

output "password" {
  depends_on   = [helm_release.aad_pod_identity]
  description  = "kubernetes password"
  value        = azurerm_kubernetes_cluster.aks.kube_config.0.password
}

output "client_certificate" {
  depends_on   = [helm_release.aad_pod_identity]
  description  = "kubernetes client certificate"
  value        = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "client_key" {
  depends_on   = [helm_release.aad_pod_identity]
  description  = "kubernetes client key"
  value        = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
}

output "cluster_ca_certificate" {
  depends_on   = [helm_release.aad_pod_identity]
  description  = "kubernetes cluster ca certificate"
  value        = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
}

output "service_principal_client_id" {
  depends_on   = [helm_release.aad_pod_identity]
  description  = "client id of the service principal used by this managed kubernetes cluster"
  value        = azurerm_kubernetes_cluster.aks.service_principal.0.client_id
}
