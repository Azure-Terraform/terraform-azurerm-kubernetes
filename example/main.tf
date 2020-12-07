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
  }
   required_version = "=0.13.5"
}

provider "azurerm" {
  features {}
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

# creates random password for admin account
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

  address_space = ["10.1.1.0/24"]

  subnets = {
    "iaas-outbound" = { cidrs = ["10.1.1.0/27"]
                        deny_all_ingress = true 
                        deny_all_egress  = true }
    "iaas-public"   = { cidrs = ["10.1.1.32/27"]
                        deny_all_ingress = true 
                        deny_all_egress  = true }
    "iaas-private"  = { cidrs = ["10.1.1.64/27"]
                        deny_all_ingress = false 
                        deny_all_egress  = false }
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
  default_node_pool_vm_size             = "Standard_D2as_v4"
  default_node_pool_enable_auto_scaling = true
  default_node_pool_node_min_count      = 1
  default_node_pool_node_max_count      = 3
  default_node_pool_availability_zones  = [1,2,3]
  default_node_pool_subnet              = "public"

  aks_managed_vnet = false
  network_plugin   = "azure"
  

  enable_windows_node_pools      = true
  windows_profile_admin_username = "testadmin"
  windows_profile_admin_password = random_password.admin.result

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
    private = {
      id                  = module.virtual_network.subnet["iaas-private"].id
      resource_group_name = module.virtual_network.vnet.resource_group_name
      security_group_name = module.virtual_network.subnet_nsg_names["iaas-private"]
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "b2s" {
  name                  = "b2ms"
  kubernetes_cluster_id = module.kubernetes.id
  vm_size               = "Standard_B2s"
  availability_zones    = [1,2,3]
  enable_auto_scaling   = true
  min_count             = 1
  max_count             = 3

  vnet_subnet_id = module.virtual_network.subnet["iaas-outbound"].id

  tags = module.metadata.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "windows_pool" {
  name                  = "win"
  kubernetes_cluster_id = module.kubernetes.id
  vm_size               = "Standard_D4_v3"
  availability_zones    = [1,2,3]
  node_count            = 1
  os_type               = "Windows"
  vnet_subnet_id        = module.virtual_network.subnet["iaas-private"].id

  tags = module.metadata.tags
}

output "aks_login" {
  value = "az aks get-credentials --name ${module.kubernetes.name} --resource-group ${module.resource_group.name}"
}
