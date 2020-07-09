variable "helm_repository" {
  description = "nginx-ingress helm repository url"
  type        = string
  default     = "https://kubernetes-charts.storage.googleapis.com"
}

variable "helm_chart_version" {
  description = "helm chart version"
  type        = string
  default     = "1.39.0"
}

variable "helm_release_name" {
  description = "helm release name"
  type        = string
}

variable "kubernetes_namespace" {
  description = "kubernetes_namespace"
  type        = string
  default     = "default"
}

variable "kubernetes_create_namespace" {
  description = "create kubernetes namespace"
  type        = bool
  default     = true
}

variable "load_balancer_ip" {
  description = "loadBalancerIP"
  type        = string
}

variable "additional_yaml_config" {
  description = "yaml config for helm chart to be processed last"
  type        = string
  default     = ""
}
