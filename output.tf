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
  description  = "auto-generated resource group which contains the resources for this managed kubernetes cluster"
  value        = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "effective_outbound_ips_ids" {
  description = "The outcome (resource IDs) of the specified arguments."
  value       = azurerm_kubernetes_cluster.aks.network_profile[0].load_balancer_profile[0].effective_outbound_ips
}
  
output "kube_config_raw" {
  description  = "raw kubernetes config to be used by kubectl and other compatible tools"
  value        = azurerm_kubernetes_cluster.aks.kube_config_raw
}

output "host" {
  description  = "kubernetes host"
  value        = azurerm_kubernetes_cluster.aks.kube_config.0.host
}

output "username" {
  description  = "kubernetes username"
  value        = azurerm_kubernetes_cluster.aks.kube_config.0.username
}

output "password" {
  description  = "kubernetes password"
  value        = azurerm_kubernetes_cluster.aks.kube_config.0.password
}

output "client_certificate" {
  description  = "kubernetes client certificate"
  value        = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "client_key" {
  description  = "kubernetes client key"
  value        = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
}

output "cluster_ca_certificate" {
  description  = "kubernetes cluster ca certificate"
  value        = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
}

output "principal_id" {
  description  = "id of the principal used by this managed kubernetes cluster"
  value        = (var.use_service_principal ? data.azuread_service_principal.aks.0.id : azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id)
}
