variable "certificate_name" {
  description = "name of certificate"
  type        = string
}

variable "helm_release_name" {
  description = "name for helm release (defauls to le-cert-<certificate_name>)"
  type        = string
  default     = ""
}

variable "namespace" {
  description = "kubernetes namespace"
  type        = string
  default     = "default"
}

variable "create_namespace" {
  description = "create kubernetes namespace"
  type        = bool
  default     = true
}

variable "secret_name" {
  description = "name of kubernetes secret"
  type        = string
}

variable "issuer_ref_name" {
  description = "name of kubernetes cluster issuer"
  type        = string
}

variable "dns_names" {
  description = "dns name(s) for certificate"
  type        = list(string)
}
