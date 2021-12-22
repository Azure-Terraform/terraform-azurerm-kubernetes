output "id" {
  description = "kubernetes managed cluster id"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "name" {
  description = "kubernetes managed cluster name"
  value       = local.cluster_name
}

output "fqdn" {
  description = "kubernetes managed cluster fqdn"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "node_resource_group" {
  description = "auto-generated resource group which contains the resources for this managed kubernetes cluster"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "effective_outbound_ips_ids" {
  description = "The outcome (resource IDs) of the specified arguments."
  value       = azurerm_kubernetes_cluster.aks.network_profile[0].load_balancer_profile[0].effective_outbound_ips
}

output "kube_config" {
  description = "kubernetes config to be used by kubectl and other compatible tools"
  value = (var.rbac.ad_integration ?
  azurerm_kubernetes_cluster.aks.kube_admin_config.0 : azurerm_kubernetes_cluster.aks.kube_config.0)
}

output "kube_config_raw" {
  description = "raw kubernetes config to be used by kubectl and other compatible tools"
  sensitive   = true
  value = (var.rbac.ad_integration ?
  azurerm_kubernetes_cluster.aks.kube_admin_config_raw : azurerm_kubernetes_cluster.aks.kube_config_raw)
}

output "host" {
  description = "kubernetes host"
  value = (var.rbac.ad_integration ?
  azurerm_kubernetes_cluster.aks.kube_admin_config.0.host : azurerm_kubernetes_cluster.aks.kube_config.0.host)
}

output "username" {
  description = "kubernetes username"
  value = (var.rbac.ad_integration ?
  azurerm_kubernetes_cluster.aks.kube_admin_config.0.username : azurerm_kubernetes_cluster.aks.kube_config.0.username)
}

output "password" {
  description = "kubernetes password"
  value = (var.rbac.ad_integration ?
  azurerm_kubernetes_cluster.aks.kube_admin_config.0.password : azurerm_kubernetes_cluster.aks.kube_config.0.password)
}

output "client_certificate" {
  description = "kubernetes client certificate"
  value = (var.rbac.ad_integration ?
  azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_certificate : azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
}

output "client_key" {
  description = "kubernetes client key"
  value = (var.rbac.ad_integration ?
  azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_key : azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
}

output "cluster_ca_certificate" {
  description = "kubernetes cluster ca certificate"
  value = (var.rbac.ad_integration ?
  azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate : azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

output "principal_id" {
  description = "id of the principal used by this managed kubernetes cluster"
  value       = local.aks_identity_id
}

output "kubelet_identity" {
  description = "kubelet identity information"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity.0
}
