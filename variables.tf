variable "resource_group_name"{
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "names" {
  description = "Names to be applied to resources."
  type        = map(string)
  default     = null
}

variable "tags" {
  description = "Tags to be applied to resources."
  type        = map(string)
}

variable "cluster_name" {
  description = "Name of AKS cluster."
  type        = string
  default     = null # null value will create name based on var.names
}

variable "dns_prefix" {
  description = "DNS prefix specified when creating the managed cluster."
  type        = string
  default     = null # null value will create name based on var.names
}

variable "node_resource_group" {
  description = "The name of the Resource Group where the Kubernetes Nodes should exist."
  type        = string
  default     = null
}

variable "identity_type" {
  description = "SystemAssigned or UserAssigned."
  type        = string
  default     = "UserAssigned"

  validation {
    condition = (
      var.identity_type == "UserAssigned" ||
      var.identity_type == "SystemAssigned"
    )
    error_message = "Identity must be one of 'SystemAssigned' or 'UserAssigned'."
  }

}

variable "user_assigned_identity" {
  description = "User assigned identity for the manged cluster (leave and the module will create one)."
  type        = object({
                  id           = string
                  principal_id = string
                  client_id    = string
                })
  default     = null
}

variable "kubernetes_version" {
  description = "kubernetes version"
  type        = string
  default     = null # defaults to latest recommended version
}

variable "network_plugin" {
  description = "network plugin to use for networking (azure or kubenet)"
  type        = string
  default     = "kubenet"
}

variable "node_pools" {
  description = "node pools"
  type        = any # top level keys are node pool names, sub-keys are subset of node_pool_defaults keys
  default     = { default = {} }
}

variable "node_pool_defaults"  {
  description = "node pool defaults"
  type        = object({
                  vm_size                            = string
                  availability_zones                 = list(number)
                  node_count                         = number
                  enable_auto_scaling                = bool
                  min_count                          = number
                  max_count                          = number
                  enable_host_encryption             = bool
                  enable_node_public_ip              = bool
                  max_pods                           = number
                  node_labels                        = map(string)
                  only_critical_addons_enabled       = bool
                  orchestrator_version               = string
                  os_disk_size_gb                    = number
                  os_disk_type                       = string
                  type                               = string
                  tags                               = map(string)
                  subnet                             = string # must be key from node_pool_subnets variable

                  # settings below not available in default node pools
                  mode                               = string
                  node_taints                        = list(string)
                  max_surge                          = string
                  eviction_policy                    = string
                  os_type                            = string
                  priority                           = string
                  proximity_placement_group_id       = string
                  spot_max_price                     = number
  })
  default     = { name                               = null
                  vm_size                            = "Standard_B2s"
                  availability_zones                 = [1,2,3]
                  node_count                         = 1
                  enable_auto_scaling                = false
                  min_count                          = null
                  max_count                          = null
                  enable_host_encryption             = false
                  enable_node_public_ip              = false
                  max_pods                           = null
                  node_labels                        = null
                  only_critical_addons_enabled       = false
                  orchestrator_version               = null
                  os_disk_size_gb                    = null
                  os_disk_type                       = "Managed"
                  type                               = "VirtualMachineScaleSets"
                  tags                               = null
                  subnet                             = null # must be a key from node_pool_subnets variable

                  # settings below not available in default node pools
                  mode                               = "User"
                  node_taints                        = null
                  max_surge                          = "1"
                  eviction_policy                    = null
                  os_type                            = "Linux"
                  priority                           = "Regular"
                  proximity_placement_group_id       = null
                  spot_max_price                     = null
  }
}

variable "default_node_pool" {
  description = "Default node pool.  Value refers to key within node_pools variable."
  type        = string
  default     = "default"
}

variable "node_pool_subnets" {
  description = "Subnet info used with node_pools variable."
  type        = map(object({
                  id                          = string # subnet_id
                  resource_group_name         = string # resource group containing virtual_network/subnets
                  network_security_group_name = string # network_security_group name associated with subnet
                }))
  default     = {}
}

variable "custom_route_table_ids" {
  description = "Custom route tables used by node pool subnets."
  type        = map(string)
  default     = {}
}

variable "configure_network_role" {
  description = "Add Network Contributor role for identity on input subnets."
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

variable "windows_profile" {
  description = "windows profile admin user/pass"
  type        = object({ 
                  admin_username = string
                  admin_password = string
                })
  default     = null

  validation {
    condition = (
      var.windows_profile == null ? true :
      ((var.windows_profile.admin_username != null) &&
       (var.windows_profile.admin_username != "") &&
       (var.windows_profile.admin_password != null) &&
       (var.windows_profile.admin_password != ""))
    )
    error_message = "Windows profile requires both admin_username and admin_password."
  }
}

variable "rbac" {
  description = "role based access control settings"
  type        = object({
                  enabled        = bool
                  ad_integration = bool
                })
  default     = {
                  enabled        = true
                  ad_integration = false
                }

  validation {
    condition = (
      (var.rbac.enabled && var.rbac.ad_integration) ||
      (var.rbac.enabled && var.rbac.ad_integration == false) ||
      (var.rbac.enabled == false && var.rbac.ad_integration == false)
    )
    error_message = "Role based access control must be enabled to use Active Directory integration."
  }
}

variable "rbac_admin_object_ids" {
  description = "Admin group object ids for use with rbac active directory integration"
  type        = map(string) # keys are only for documentation purposes
  default     = {}
}

variable "enable_kube_dashboard" {
  description = "enable kubernetes dashboard"
  type        = bool
  default     = false
}

variable "acr_pull_access" {
  description = "map of ACR ids to allow AcrPull"
  type        = map(string)
  default     = {}
}