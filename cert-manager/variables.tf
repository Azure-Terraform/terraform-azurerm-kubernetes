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

variable "letsencrypt_endpoint" {
  description = "letsencrypt endpoint (https://letsencrypt.org/docs/acme-protocol-updates).  Allowable inputs are 'staging', 'production' or a full URL."
  type        = string
  default     = "staging"
}

variable "email_address" {
  description = "email address used for expiration notification"
  type        = string
}

variable "cert_manager_version" {
  description = "cert-manager helm chart version"
  type        = string
  default     = "v0.15.0"
}

variable "domains" {
  description = "domains certificates will be generated for"
  type        = list(string)
}

locals {
  le_endpoint = {
    "staging"    = "https://acme-staging-v02.api.letsencrypt.org/directory"
    "production" = "https://acme-v02.api.letsencrypt.org/directory"
  }
}
