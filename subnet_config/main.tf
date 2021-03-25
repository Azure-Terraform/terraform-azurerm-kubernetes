resource "azurerm_role_assignment" "subnet_network_contributor" {
  count                = (var.configure_network_role ? 1 : 0)
  scope                = var.subnet_info.id
  role_definition_name = "Network Contributor"
  principal_id         = var.principal_id
}

resource "azurerm_network_security_rule" "aks_control_plane_udp" {
  count                       = (var.configure_nsg_rules ? 1 : 0)
  name                        = "AKS_AllowControlPlaneUDP"
  priority                    = (var.nsg_rule_priority_start)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "udp"
  source_port_range           = "*"
  destination_port_range      = "1194"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureCloud"
  resource_group_name         = var.subnet_info.resource_group_name
  network_security_group_name = var.subnet_info.network_security_group_name
}

resource "azurerm_network_security_rule" "aks_control_plane_tcp" {
  count                       = (var.configure_nsg_rules ? 1 : 0)
  name                        = "AKS_AllowControlPlaneTCP"
  priority                    = (var.nsg_rule_priority_start + 1)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "9000"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureCloud"
  resource_group_name         = var.subnet_info.resource_group_name
  network_security_group_name = var.subnet_info.network_security_group_name
}

resource "azurerm_network_security_rule" "aks_ntp" {
  count                       = (var.configure_nsg_rules ? 1 : 0)
  name                        = "AKS_AllowNTP"
  priority                    = (var.nsg_rule_priority_start + 2)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "udp"
  source_port_range           = "*"
  destination_port_range      = "123"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.subnet_info.resource_group_name
  network_security_group_name = var.subnet_info.network_security_group_name
}

resource "azurerm_network_security_rule" "aks_ssl" {
  count                       = (var.configure_nsg_rules ? 1 : 0)
  name                        = "AKS_AllowSSL"
  priority                    = (var.nsg_rule_priority_start + 3)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureCloud"
  resource_group_name         = var.subnet_info.resource_group_name
  network_security_group_name = var.subnet_info.network_security_group_name
}

resource "azurerm_network_security_rule" "aks_front_door_ssl" {
  count                       = (var.configure_nsg_rules ? 1 : 0)
  name                        = "AKS_AllowFrontDoor"
  priority                    = (var.nsg_rule_priority_start + 4)
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureFrontDoor.FirstParty"
  resource_group_name         = var.subnet_info.resource_group_name
  network_security_group_name = var.subnet_info.network_security_group_name
}