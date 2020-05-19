# Kubernetes 
variable "kubectl_host" {
  description = "kubernetes hostname"
  type        = string
}

variable "kubectl_client_certificate" {
  description = "kubernetes client certificate"
  type        = string
}

variable "kubectl_client_key" {
  description = "kubernetes certificate key"
  type        = string
}

variable "kubectl_cluster_ca_certificate" {
  description = "kubernetes certificate bundle"
  type        = string
}

variable "helm_name" {
  description = "name of helm installation (defaults to pod-id-<identity_name>"
  type        = string
  default     = ""
}

variable "identity_name" {
  description = "name for Azure identity to be used by AAD"
  type        = string
}


variable "identity_client_id" {
  description = "client id of the managed identity"
  type        = string
}

variable "identity_resource_id" {
  description = "resource id of the managed identity"
  type        = string
}
