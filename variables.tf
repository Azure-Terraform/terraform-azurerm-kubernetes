# Basics
variable "use_service_principal" {
  description = "use service principal (false will use identity)"
  type        = bool
  default     = false
}

variable "identity_type" {
  description = "ServicePrincipal, SystemAssigned or UserAssigned."
  type        = string
  default     = "UserAssigned"

  validation {
    condition = (
      var.identity_type == "ServicePrincipal" ||
      var.identity_type == "UserAssigned" ||
      var.identity_type == "SystemAssigned"
    )
    error_message = "Identity must be one of 'ServicePrincipal', 'SystemAssigned' or 'UserAssigned'."
  }

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

variable "user_assigned_identity" {
  description = "User assigned identity for the manged cluster (leave and the module will create one)."
  type        = object({
                  id             = string
                  name           = string
                  resource_group = string
                })
  default     = null
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

variable "network_plugin" {
  description = "network plugin to use for networking (azure or kubenet)"
  type        = string
  default     = "kubenet"
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

variable "aks_managed_vnet" {
  description = "use AKS managed vnet/subnet (false requires default_node_pool_subnet and node_pool_subnets is specified)"
  type        = bool
  default     = true
}

variable "default_node_pool_subnet" {
  description = "name of key from node_pool_subnets map to use for default node pool"
  type        = string
  default     = ""
}

variable "node_pool_subnets" {
  description = "Node pool subnet info."
  type        = map(object({
                  name                 = string
                  id                   = string
                  resource_group_name  = string
                  security_group_name  = string
                  virtual_network_name = string
                }))
  default     = {}
}

variable "custom_route_table_ids" {
  description = "Custom route tables used by node pool subnets."
  type        = map(string)
  default     = {}
}

variable "configure_network_role" {
  description = "Add Network Contributor role for service principal or identity on input subnets."
  type        = bool
  default     = true
}

variable "configure_subnet_nsg_rules" {
  description = "Configure required AKS NSG rules on input subnets."
  type        = bool
  default     = true
}

variable "subnet_nsg_rule_priority_start" {
  description = "Starting point for NSG rulee priorities."
  type        = number
  default     = 1000
}

variable "enable_windows_node_pools" {
  description = "configure profile for windows node pools (requires windows_profile_admin_username/password)"
  type        = bool
  default     = false
}

variable "windows_profile_admin_username" {
  description = "windows profile admin username"
  type        = string
  default     = "aks-windows-admin"
}

variable "windows_profile_admin_password" {
  description = "windows profile admin password"
  type        = string
  default     = ""
}

variable "enable_kube_dashboard" {
  description = "enable kubernetes dashboard"
  type        = bool
  default     = true
}
