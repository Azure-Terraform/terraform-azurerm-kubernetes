variable "principal_id" {
  description = "Id of principal which manages AKS"
  type        = string
}

variable "subnet_info" {
  description = "Azure virtual network subnet id."
  type        = map(object({
                  id                          = string
                  resource_group_name         = string
                  network_security_group_name = string
                }))
}

variable "configure_network_role" {
  description = "Add Netowrk Contributor Role for subnet to AKS service principal."
  type        = bool
}

variable "configure_nsg_rules" {
  description = "Configure subnet NSG rules for AKS."
  type        = bool
}

variable "nsg_rule_priority_start" {
  description = "Starting point for NSG rulee priorities."
  type        = number
}
