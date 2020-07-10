# Basics
variable "use_service_principal" {
  description = "use service principal (false will use SystemAssigned identity)"
  type        = bool
  default     = false
}

variable "service_principal_id" {
  description = "Azure Service Principal ID"
  type        = string
  default     = ""
}

variable "service_principal_secret" {
  description = "Azure Service Principal Secret"
  type        = string
  default     = ""
}

variable "service_principal_name" {
  description = "Azure Service Principal Name"
  type        = string
  default     = ""
}

variable "resource_group_name"{
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
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

# AKS
variable "kubernetes_version" {
  description = "kubernetes version"
  type        = string
}

variable "default_node_pool_name" {
  description = "default node pool name"
  type        = string
  default     = "default"
}

variable "default_node_pool_vm_size" {
  description = "default node pool VM size"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "default_node_pool_node_count" {
  description  = "default node pool node count"
  type         = number
  default      = 1
}

variable "default_node_pool_enable_auto_scaling" {
  description = "enable default node pool auto scaling"
  type        = bool
  default     = true
}

variable "default_node_pool_node_min_count" {
  description = "enable default node pool auto scaling (only valid for auto scaling)"
  type        = number
  default     = 1
}

variable "default_node_pool_node_max_count" {
  description = "enable default node pool auto scaling (only valid with auto scaling)"
  type        = number
  default     = 5
}

variable "default_node_pool_availability_zones" {
  description = "default node pool availability zones"
  type        = list(number)
  default     = [1,2,3]
}

variable "enable_aad_pod_identity" {
  description = "enable Azure AD pod identity enable kubernetes dashboard"
  type        = bool
  default     = true
}

variable "enable_kube_dashboard" {
  description = "enable kubernetes dashboard"
  type        = bool
  default     = true
}

# kured variables
variable "enable_kured" {
  description = "enable kured"
  type        = bool
  default     = false
}

variable "kured_namespace" {
  description = "namespace to use for kured. It will be created if namespace does not already exist"
  type        = string
  default     = null
}

variable "kured_version" {
  description = "the version to add for kured"
  type        = string
  default     = null
}