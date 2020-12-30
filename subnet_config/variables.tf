variable "configure_network_role" {
  description = "Add Netowrk Contributor Role for subnet to AKS service principal."
  type        = bool
}

variable "principal_id" {
  description = "Id of principal which manages AKS"
  type        = string
}

variable "configure_nsg_rules" {
  description = "Configure subnet NSG rules for AKS."
  type        = bool
}

variable "nsg_rule_priority_start" {
  description = "Starting point for NSG rulee priorities."
  type        = number
}

variable "resource_group_name" {
  description = "Resource group in which to creat the network security group rules."
  type        = string
}

variable "subnet_id" {
  description = "Azure virtual network subnet id."
  type        = string
}

variable "security_group_name" {
  description = "Name of security group associated with subnet."
  type        = string
}
