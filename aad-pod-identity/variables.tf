variable "helm_chart_version" {
  description = "Azure AD pod identity helm chart version"
  type        = string
  default     = "2.0.0"
}

variable "node_resource_group_name" {
  description = "AKS node resource group name"
  type        = string
}

variable "principal_id" {
  description = "AKS principal id"
  type        = string
}

variable "additional_scopes" {
  description = "identity scopes residing outside of AKS MC_resource_group (resource group id or identity id would be a common input)"
  type        = list(string)
  default     = []
}
