# Azure - Kubernetes Module

## Introduction

This module will create a managed Kubernetes cluster using Azure Kubernetes Service.
<br />

<!--- BEGIN_TF_DOCS --->
## Providers

| Name | Version |
|------|---------|
| azuread | n/a |
| azurerm | >= 2.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| default\_node\_pool\_availability\_zones | default node pool availability zones | `list(number)` | <pre>[<br>  1,<br>  2,<br>  3<br>]</pre> | no |
| default\_node\_pool\_enable\_auto\_scaling | enable default node pool auto scaling | `bool` | `true` | no |
| default\_node\_pool\_name | default node pool name | `string` | `"default"` | no |
| default\_node\_pool\_node\_count | default node pool node count | `number` | `1` | no |
| default\_node\_pool\_node\_max\_count | enable default node pool auto scaling (only valid with auto scaling) | `number` | `5` | no |
| default\_node\_pool\_node\_min\_count | enable default node pool auto scaling (only valid for auto scaling) | `number` | `1` | no |
| default\_node\_pool\_vm\_size | default node pool VM size | `string` | `"Standard_D2s_v3"` | no |
| enable\_aad\_pod\_identity | enable Azure AD pod identity enable kubernetes dashboard | `bool` | `true` | no |
| enable\_kube\_dashboard | enable kubernetes dashboard | `bool` | `true` | no |
| kubernetes\_version | kubernetes version | `string` | `"1.16.7"` | no |
| location | Azure Region | `string` | n/a | yes |
| names | names to be applied to resources | `map(string)` | n/a | yes |
| resource\_group\_name | Resource group name | `string` | n/a | yes |
| service\_principal\_id | Azure Service Principal ID | `string` | n/a | yes |
| service\_principal\_name | Azure Service Principal Name | `string` | n/a | yes |
| service\_principal\_secret | Azure Service Principal Secret | `string` | n/a | yes |
| tags | tags to be applied to resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| client\_certificate | kubernetes client certificate |
| client\_key | kubernetes client key |
| cluster\_ca\_certificate | kubernetes cluster ca certificate |
| fqdn | kubernetes managed cluster fqdn |
| host | kubernetes host |
| id | kubernetes managed cluster id |
| kube\_config\_raw | raw kubernetes config to be used by kubectl and other compatible tools |
| node\_resource\_group | auto-generated resource group which contains the resources for this managed kubernetes cluster |
| password | kubernetes password |
| service\_principal\_client\_id | client id of the service principal used by this managed kubernetes cluster |
| username | kubernetes username |
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

module "aad-pod-identity" {
  source = "git@github.com:LexisNexis-Terraform/terraform-azurerm-kubernetes.git/aad-pod-identity"
  
  providers = {
    helm = helm.aks
  }

  resource_group_name    = module.resource_group.name
  service_principal_name = "ris-azr-app-infrastructure-aks-test"

  aad_pod_identity_version = "1.6.0"
}
~~~~