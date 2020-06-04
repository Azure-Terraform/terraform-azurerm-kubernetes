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

variable "cert_manager_version" {
  description = "enable cert-manager helm chart"
  type        = string
  default     = "v0.15.0"
}

variable "domains" {
  description = "domains certificates will be generated for"
  type        = list(string)
}
