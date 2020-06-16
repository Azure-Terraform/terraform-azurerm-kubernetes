variable "subscription_id"{
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name"{
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
}

variable "names" {
  description = "names to be applied to resources"
  type        = map(string)
}

variable "tags" {
  description = "tags to be applied to resources"
  type        = map(string)
}

variable "name_identifier" {
  description = "allows for unique resources when multiple aks cluster exist in same environment"
  type        = string
  default     = ""
}

variable "cert_manager_version" {
  description = "cert-manager helm chart version"
  type        = string
  default     = "v0.15.0"
}

variable "helm_release_name" {
  description = "helm release name"
  type        = string
  default     = "cert-manager"
}

variable "kubernetes_namespace" {
  description = "kubernetes namespace"
  type        = string
  default     = "cert-manager"
}

variable "create_kubernetes_namespace" {
  description = "create kubernetes namespace if not present"
  type        = bool
  default     = true
}

variable "install_crds" {
  description = "install cert-manager crds"
  type        = bool
  default     = true
}

variable "domains" {
  description = "domains certificates will be generated for"
  type        = set(string)
}

variable "additional_yaml_config" {
  description = "yaml config for helm chart to be processed last"
  type        = string
  default     = ""
}

variable "issuers" {
  default = {} 
  type    = map(object({
    namespace             = string # kubernetes namespace
    cluster_issuer        = bool   # setting 'true' will create a ClusterIssuer, setting 'false' will create a namespace isolated Issuer
    email_address         = string # email address used for expiration notification
    domain                = string # azuredns hosted domain (must be listed in var.domains)
    letsencrypt_endpoint  = string # letsencrypt endpoint (https://letsencrypt.org/docs/acme-protocol-updates).  Allowable inputs are 'staging', 'production' or a full URL
  }))
}

locals {
  delimiter   = (var.name_identifier == "" ? "" : "-")
  le_endpoint = {
    "staging"    = "https://acme-staging-v02.api.letsencrypt.org/directory"
    "production" = "https://acme-v02.api.letsencrypt.org/directory"
  }
}
