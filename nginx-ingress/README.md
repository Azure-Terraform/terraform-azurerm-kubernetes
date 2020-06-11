# Azure - Kubernetes NGINX ingress Module

## Introduction

This module will install an NGINX ingress module into an AKS cluster.  This is largely to bridge the gap between AzureDNS/Azure Static IP/AKS.
<br />

<!--- BEGIN_TF_DOCS --->
## Providers

| Name | Version |
|------|---------|
| helm | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| additional\_yaml\_config | yaml config for helm chart to be processed last | `string` | `""` | no |
| helm\_chart\_version | helm chart version | `string` | `"1.39.0"` | no |
| helm\_release\_name | helm release name | `string` | `"nginx-ingress"` | no |
| helm\_repository | nginx-ingress helm repository url | `string` | `"https://kubernetes-charts.storage.googleapis.com"` | no |
| kubernetes\_create\_namespace | create kubernetes namespace | `bool` | `false` | no |
| kubernetes\_namespace | kubernetes\_namespace | `string` | `"default"` | no |
| load\_balancer\_ip | loadBalancerIP | `string` | n/a | yes |

## Outputs

No output.
<!--- END_TF_DOCS --->
## Example

~~~~
provider "azurerm" {
  version = ">=2.0.0"
  features {}
  subscription_id = "00000-0000-0000-0000-0000000"
}

# Subscription
module "subscription" {
  source = "git@github.com:LexisNexis-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
}

# Metadata
module "metadata" {
  source = "git@github.com:LexisNexis-Terraform/terraform-azurerm-metadata.git?ref=v1.0.0"

  subscription_id     = module.subscription.output.subscription_id
  # These values should be taken from https://github.com/openrba/python-azure-naming
  business_unit       = "rba.businessUnit"
  cost_center         = "rba.costCenter"
  environment         = "rba.environment"
  location            = "rba.azureRegion"
  market              = "rba.market"
  product_name        = "rba.productName"
  product_group       = "rba.productGroup"
  project             = "project-url"
  sre_team            = "team-name"
  subscription_type   = "rba.subscriptionType"
  resource_group_type = "rba.resourceGroupType"

  additional_tags = {
    "example" = "an additional tag"
  }
}

# Resource group
module "resource_group" {
  source = "git@github.com:LexisNexis-Terraform/terraform-azurerm-resource-group.git?ref=v1.0.0"

  location = module.metadata.location
  tags     = module.metadata.tags
  name     = module.metadata.names
}

# AKS
## This will create a managed kubernetes cluster
module "aks" {
  source = "git@github.com:LexisNexis-Terraform/terraform-azurerm-kubernetes.git"

  service_principal_id     = var.service_principal_id
  service_principal_secret = var.service_principal_secret
  service_principal_name   = "ris-azr-app-infrastructure-aks-test"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  names = module.metadata.names
  tags  = module.metadata.tags

  kubernetes_version = "1.16.7"

  default_node_pool_name                = "default"
  default_node_pool_vm_size             = "Standard_D2s_v3"
  default_node_pool_enable_auto_scaling = true
  default_node_pool_node_min_count      = 1
  default_node_pool_node_max_count      = 5
  default_node_pool_availability_zones  = [1,2,3]

  enable_kube_dashboard = true
  
}

module "dns" {
  source = "github.com/Azure-Terraform/terraform-azurerm-dns-zone.git"

  domain_prefix = "foo.bar.com"

  iog_resource_group_name = module.resource_group.name
  iog_subscription_id     = module.subscription.id
  sre_resource_group_name = module.resource_group.name
  sre_subscription_id     = "00000-0000-0000-0000-0000000"

  names               = module.metadata.names
  tags                = module.metadata.tags
}

resource "azurerm_public_ip" "demo" {
  name                = "demo"
  resource_group_name = module.aks.node_resource_group
  location            = module.resource_group.location
  allocation_method   = "Static"

  sku = "Standard"

  tags = module.metadata.tags
}

resource "azurerm_dns_a_record" "demo" {
  name                = "demo"
  zone_name           = module.dns.name
  resource_group_name = module.resource_group.name
  ttl                 = 60
  records             = [azurerm_public_ip.demo.ip_address]
}

# Helm
provider "helm" {
  alias = "aks"
  kubernetes {
    host                   = module.aks.host
    client_certificate     = base64decode(module.aks.client_certificate)
    client_key             = base64decode(module.aks.client_key)
    cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
  }
}

module "nginx_ingress" {
  source = "git@github.com:Azure-Terraform/terraform-azurerm-kubernetes.git/nginx-ingress"

  providers = {
    helm = helm.aks
  }

  kubernetes_namespace = "demo"
  load_balancer_ip     = azurerm_public_ip.demo.ip_address
}
