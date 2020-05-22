variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "service_principal_name" {
  description = "Azure Service Principal Name"
  type        = string
}

variable "aad_pod_identity_version" {
  description = "Azure AD pod identity helm chart version"
  type        = string
  default     = "1.6.0"
}
