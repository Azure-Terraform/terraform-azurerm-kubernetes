# Azure - Kubernetes Pod Identity Module

## Introduction

This module will enalbe pod identity within a managed Kubernetes cluster hosted on Azure Kubernetes Service.
<br />

<!--- BEGIN_TF_DOCS --->
## Providers

| Name | Version |
|------|---------|
| helm | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| helm\_name | name of helm installation (defaults to pod-id-<identity\_name> | `string` | `""` | no |
| identity\_client\_id | client id of the managed identity | `string` | n/a | yes |
| identity\_name | name for Azure identity to be used by AAD | `string` | n/a | yes |
| identity\_resource\_id | resource id of the managed identity | `string` | n/a | yes |
| kubectl\_client\_certificate | kubernetes client certificate | `string` | n/a | yes |
| kubectl\_client\_key | kubernetes certificate key | `string` | n/a | yes |
| kubectl\_cluster\_ca\_certificate | kubernetes certificate bundle | `string` | n/a | yes |
| kubectl\_host | kubernetes hostname | `string` | n/a | yes |

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

resource "azurerm_user_assigned_identity" "test" {
  name                 = "test"
  location             = var.location
  resource_group_name  = var.resource_group_name
  tags                 = var.tags
}

module "test_identity" {
  source = "/Users/tmiller/gitlab-repos/tfe/terraform-azurerm-kubernetes/aad-pod-identity/identity"

  providers = {
    helm = helm.aks
  }

  identity_name        = azurerm_user_assigned_identity.test.name
  identity_client_id   = azurerm_user_assigned_identity.test.client_id
  identity_resource_id = azurerm_user_assigned_identity.test.id

}
~~~~