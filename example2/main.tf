terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.32.0"
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
    docker = {
      source  = "kreuzwerker/docker"
      version = "=2.8.0"
    }
  }
   required_version = "=0.13.5"
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
  length      = 14
  special     = true
}

module "subscription" {
  source = "github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

module "rules" {
  source = "git@github.com:openrba/python-azure-naming.git?ref=tf"
}

module "metadata" {
  source = "github.com/Azure-Terraform/terraform-azurerm-metadata.git?ref=v1.1.0"

  naming_rules = module.rules.yaml

  market              = "us"
  project             = "https://gitlab.ins.risk.regn.net/example/"
  location            = "useast2"
  sre_team            = "iog-core-services"
  environment         = "sandbox"
  product_name        = random_string.random.result
  business_unit       = "iog"
  product_group       = "core"
  subscription_id     = module.subscription.output.subscription_id
  subscription_type   = "nonprod"
  resource_group_type = "app"
}

module "resource_group" {
  source = "github.com/Azure-Terraform/terraform-azurerm-resource-group.git?ref=v1.0.0"

  location = module.metadata.location
  names    = module.metadata.names
  tags     = module.metadata.tags
}

module "virtual_network" {
  source = "github.com/Azure-Terraform/terraform-azurerm-virtual-network.git?ref=v2.2.0"

  naming_rules = module.rules.yaml

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  names               = module.metadata.names
  tags                = module.metadata.tags

  address_space = ["10.1.0.0/22"]

  subnets = {
    "iaas-outbound" = { cidrs = ["10.1.0.0/24"]
                        deny_all_ingress = true
                        deny_all_egress  = true }
    "iaas-public"   = { cidrs = ["10.1.1.0/24"]
                        deny_all_ingress = true 
                        deny_all_egress  = true }
  }
}

module "kubernetes" {
  source = "../"

  kubernetes_version = "1.18.10"

  location                 = module.metadata.location
  names                    = module.metadata.names
  tags                     = module.metadata.tags
  resource_group_name      = module.resource_group.name

  use_service_principal = false

  default_node_pool_name                = "default"
  default_node_pool_vm_size             = "Standard_DS2_v2"
  default_node_pool_enable_auto_scaling = true
  default_node_pool_node_min_count      = 3
  default_node_pool_node_max_count      = 9
  default_node_pool_availability_zones  = [1,2,3]
  default_node_pool_subnet              = "public"

  enable_windows_node_pools      = true
  windows_profile_admin_username = "testadmin"
  windows_profile_admin_password = random_password.admin.result

  network_plugin             = "azure"
  aks_managed_vnet           = false
  configure_subnet_nsg_rules = true

  node_pool_subnets = {
    public = {
      id                  = module.virtual_network.subnet["iaas-public"].id
      resource_group_name = module.virtual_network.vnet.resource_group_name
      security_group_name = module.virtual_network.subnet_nsg_names["iaas-public"]
    }
    outbound = {
      id                  = module.virtual_network.subnet["iaas-outbound"].id
      resource_group_name = module.virtual_network.vnet.resource_group_name
      security_group_name = module.virtual_network.subnet_nsg_names["iaas-outbound"]
    }
  }
}

resource "azurerm_network_security_rule" "outbound_ssl" {
  for_each                    = module.virtual_network.subnet_nsg_names
  name                        = "Allow_SSL"
  priority                    = 3000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.resource_group.name
  network_security_group_name = each.value
}

resource "azurerm_network_security_rule" "outbound_vnet" {
  for_each                    = module.virtual_network.subnet_nsg_names
  name                        = "AllowVnetOut"
  priority                    = 3001
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = module.resource_group.name
  network_security_group_name = each.value
}

resource "azurerm_network_security_rule" "inbound_vnet" {
  for_each                    = module.virtual_network.subnet_nsg_names
  name                        = "AllowVnetIn"
  priority                    = 3001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = module.resource_group.name
  network_security_group_name = each.value
}

#resource "azurerm_network_security_rule" "outbound_internet" {
#  for_each                    = module.virtual_network.subnet_nsg_names
#  name                        = "Allow_Outbound_Internet"
#  priority                    = 3002
#  direction                   = "Outbound"
#  access                      = "Allow"
#  protocol                    = "*"
#  source_port_range           = "*"
#  destination_port_range      = "*"
#  source_address_prefix       = "*"
#  destination_address_prefix  = "Internet"
#  resource_group_name         = module.resource_group.name
#  network_security_group_name = each.value
#}

output "aks_login" {
  value = "az aks get-credentials --name ${module.kubernetes.name} --resource-group ${module.resource_group.name}"
}
