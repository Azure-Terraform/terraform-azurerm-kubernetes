terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.44.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=2.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=1.13.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "=1.3.2"
    }
  }
  required_version = ">=0.14.7"
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = module.kubernetes.host
  client_certificate     = base64decode(module.kubernetes.client_certificate)
  client_key             = base64decode(module.kubernetes.client_key)
  cluster_ca_certificate = base64decode(module.kubernetes.cluster_ca_certificate)
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = module.kubernetes.host
    client_certificate     = base64decode(module.kubernetes.client_certificate)
    client_key             = base64decode(module.kubernetes.client_key)
    cluster_ca_certificate = base64decode(module.kubernetes.cluster_ca_certificate)
  }
}

data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "azurerm_subscription" "current" {
}

resource "random_string" "random" {
  length  = 12
  upper   = false
  number  = false
  special = false
}

resource "random_password" "admin" {
  length  = 14
  special = true
}

module "subscription" {
  source          = "github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

module "naming" {
  source = "github.com/Azure-Terraform/example-naming-template.git?ref=v1.0.0"
}

module "metadata" {
  source = "github.com/Azure-Terraform/terraform-azurerm-metadata.git?ref=v1.5.0"

  naming_rules = module.naming.yaml

  market              = "us"
  project             = "https://github.com/Azure-Terraform/terraform-azurerm-kubernetes/tree/master/example/mixed-arch"
  location            = "eastus2"
  environment         = "sandbox"
  product_name        = random_string.random.result
  business_unit       = "infra"
  product_group       = "bridgertest05"
  subscription_id     = module.subscription.output.subscription_id
  subscription_type   = "dev"
  resource_group_type = "app"
}

data "azurerm_resource_group" "rg" {
  name = "test-aks-deployment-01"
}

data "azurerm_virtual_network" "vnet" {
  name                = "vnet-test-aks-deployment-01"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "iaas_private" {
  name                 = "iaas-private"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

module "kubernetes" {
  source = "github.com/Azure-Terraform/terraform-azurerm-kubernetes.git?ref=v2.0.0"

  kubernetes_version = "1.19.7"

  location            = data.azurerm_resource_group.rg.location
  names               = module.metadata.names
  tags                = module.metadata.tags
  resource_group_name = data.azurerm_resource_group.rg.name

  identity_type = "UserAssigned"

  default_node_pool_name                = "default"
  default_node_pool_vm_size             = "Standard_B2s"
  default_node_pool_enable_auto_scaling = true
  default_node_pool_node_min_count      = 1
  default_node_pool_node_max_count      = 3
  default_node_pool_availability_zones  = [1, 2, 3]
  default_node_pool_subnet              = "private"

  enable_windows_node_pools      = true
  windows_profile_admin_username = "azadmin"
  windows_profile_admin_password = random_password.admin.result

  network_plugin             = "azure"
  aks_managed_vnet           = false
  configure_subnet_nsg_rules = true
  enable_kube_dashboard      = false

  node_pool_subnets = {
    private = {
      id                          = data.azurerm_subnet.iaas_private.id
      resource_group_name         = data.azurerm_resource_group.rg.name
      network_security_group_name = azurerm_network_security_group.nsg.name
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "linux_webservers" {
  name                  = "linuxweb"
  kubernetes_cluster_id = module.kubernetes.id
  vm_size               = "Standard_B2s"
  availability_zones    = [1, 2, 3]
  enable_auto_scaling   = true
  min_count             = 1
  max_count             = 3

  vnet_subnet_id = data.azurerm_virtual_network.vnet.id

  tags = module.metadata.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "windows_webservers" {
  name                  = "winweb"
  kubernetes_cluster_id = module.kubernetes.id
  vm_size               = "Standard_D2_v3"
  availability_zones    = [1, 2, 3]
  node_count            = 1
  os_type               = "Windows"
  vnet_subnet_id        = data.azurerm_virtual_network.vnet.id

  tags = module.metadata.tags
}

##
# Existing Vnet and Subnet 
##

resource "azurerm_route_table" "route_table" {
  name                          = "AKS-routetable"
  location                      = data.azurerm_resource_group.rg.location
  resource_group_name           = data.azurerm_resource_group.rg.name
  disable_bgp_route_propagation = true
}

resource "azurerm_route" "internet" {
  name                = "acceptanceTestRoute1"
  resource_group_name = data.azurerm_resource_group.rg.name
  route_table_name    = azurerm_route_table.route_table.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}

resource "azurerm_route" "internal_01" {
  name                = "acceptanceTestRoute1"
  resource_group_name = data.azurerm_resource_group.rg.name
  route_table_name    = azurerm_route_table.route_table.name
  address_prefix      = "10.0.0.0/8"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = "10.239.0.68"
}

resource "azurerm_route" "internal_02" {
  name                = "acceptanceTestRoute1"
  resource_group_name = data.azurerm_resource_group.rg.name
  route_table_name    = azurerm_route_table.route_table.name
  address_prefix      = "172.16.0.0/12"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = "10.239.0.68"
}

resource "azurerm_route" "internal_03" {
  name                = "acceptanceTestRoute1"
  resource_group_name = data.azurerm_resource_group.rg.name
  route_table_name    = azurerm_route_table.route_table.name
  address_prefix      = "192.168.0.0/16"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = "10.239.0.68"
}

resource "azurerm_route" "local_vnet" {
  name                = "acceptanceTestRoute1"
  resource_group_name = data.azurerm_resource_group.rg.name
  route_table_name    = azurerm_route_table.route_table.name
  address_prefix      = "10.1.1.0/24"
  next_hop_type       = "vnetlocal"
}

resource "azurerm_subnet_route_table_association" "association" {
  subnet_id      = data.azurerm_subnet.iaas_private.id
  route_table_id = azurerm_route_table.route_table.id
}

resource "azurerm_virtual_network_peering" "peer" {
  name                         = "vnet-peering-iaas-private"
  resource_group_name          = data.azurerm_resource_group.rg.name
  virtual_network_name         = data.azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = data.azurerm_virtual_network.vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = data.azurerm_subnet.iaas_private.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_security_group" "nsg" {
  name                = "app-${random_string.random.result}-iaas-private-security-group"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = module.metadata.tags
}

resource "azurerm_network_security_rule" "deny_all_inbound" {
  name                        = "DenyAllInbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "deny_all_outbound" {
  name                        = "DenyAllOutbound"
  priority                    = 4096
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "allow_vnet_inbound" {
  name                        = "AllowVnetIn"
  priority                    = 4094
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "allow_vnet_outbound" {
  name                        = "AllowVnetOut"
  priority                    = 4094
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "allow_internet_outbound" {
  name                        = "AllowInternetOut"
  priority                    = 4095
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "ingress_public_allow_nginx" {
  name                        = "AllowNginx"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = data.kubernetes_service.nginx.load_balancer_ingress.0.ip
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "ingress_public_allow_iis" {
  name                        = "AllowIIS"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = data.kubernetes_service.iis.load_balancer_ingress.0.ip
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

##
# EOF for existing vnet and subnet
##

resource "helm_release" "nginx" {
  depends_on = [azurerm_kubernetes_cluster_node_pool.linux_webservers]
  name       = "nginx"
  chart      = "./helm_chart"

  set {
    name  = "name"
    value = "nginx"
  }

  set {
    name  = "image"
    value = "nginx:latest"
  }

  set {
    name  = "nodeSelector"
    value = yamlencode({ agentpool = "linuxweb" })
  }
}

resource "helm_release" "iis" {
  depends_on = [azurerm_kubernetes_cluster_node_pool.windows_webservers]
  name       = "iis"
  chart      = "./helm_chart"
  timeout    = 600

  set {
    name  = "name"
    value = "iis"
  }

  set {
    name  = "image"
    value = "microsoft/iis:latest"
  }

  set {
    name  = "nodeSelector"
    value = yamlencode({ agentpool = "winweb" })
  }
}

data "kubernetes_service" "nginx" {
  depends_on = [helm_release.nginx]
  metadata {
    name = "nginx"
  }
}

data "kubernetes_service" "iis" {
  depends_on = [helm_release.iis]
  metadata {
    name = "iis"
  }
}

output "nginx_url" {
  value = "http://${data.kubernetes_service.nginx.load_balancer_ingress.0.ip}"
}

output "iis_url" {
  value = "http://${data.kubernetes_service.iis.load_balancer_ingress.0.ip}"
}

output "aks_login" {
  value = "az aks get-credentials --name ${module.kubernetes.name} --resource-group ${data.azurerm_resource_group.rg.name}"
}
