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

variable "network_plugin" {
  description = "network plugin to use for networking (azure or kubenet)"
  type        = string
  default     = "kubenet"
}

node_pool_defaults = {
  description = "node pool defaults"
  type        = object({
                  name                         = string
                  vm_size                      = string
                  availability_zones           = list(number)
                  node_count                   = number
                  enable_auto_scaling          = bool
                  min_count                    = number
                  max_count                    = number
                  enable_host_encryption       = bool
                  enable_node_public_ip        = bool
                  max_pods                     = number
                  node_labels                  = map(string)
                  only_critical_addons_enabled = bool
                  orchestrator_version         = string
                  os_disk_size_gb              = number
                  os_disk_type                 = string
                  type                         = string
                  tags                         = map(string)
                  vnet_subnet_id               = string

                  eviction_policy              = string
                  os_type                      = string
                  priority                     = string
                  proximity_placement_group_id = string
                  spot_max_price               = string 
  })
  default     = { name                         = "default"
                  vm_size                      = "Standard_B2s"
                  availability_zones           = [1,2,3]
                  node_count                   = 1
                  enable_auto_scaling          = false
                  min_count                    = 1
                  max_count                    = 2
                  enable_host_encryption       = true
                  enable_node_public_ip        = false
                  max_pods                     = 30
                  node_labels                  = {}
                  only_critical_addons_enabled = false
                  orchestrator_version         = null
                  os_disk_size_gb              = 128
                  os_disk_type                 = "Managed"
                  type                         = "VirtualMachineScaleSets"
                  tags                         = {}
                  vnet_subnet_id               = null

                  eviction_policy              = null
                  os_type                      = "Linux"
                  priority                     = "Regular"
                  proximity_placement_group_id = null
                  spot_max_price               = null
  }
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
  description = "default node pool vnet subnet info"
  type        = map(object({
                  id                  = string
                  resource_group_name = string
                  security_group_name = string
                }))
  default     = {}
}

variable "configure_sp_subnet_role" {
  description = "Add Network Contributor role for service principal on input subnets."
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

variable "enable_aad_pod_identity" {
  description = "enable Azure AD pod identity enable kubernetes dashboard"
  type        = bool
  default     = true
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
