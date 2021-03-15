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
| acr\_pull\_access | map of ACR ids to allow AcrPull | `map(string)` | `{}` | no |
| aks\_managed\_vnet | use AKS managed vnet/subnet (false requires default\_node\_pool\_subnet and node\_pool\_subnets is specified) | `bool` | `true` | no |
| configure\_network\_role | Add Network Contributor role for service principal or identity on input subnets. | `bool` | `true` | no |
| configure\_subnet\_nsg\_rules | Configure required AKS NSG rules on input subnets. | `bool` | `true` | no |
| custom\_route\_table\_ids | Custom route tables used by node pool subnets. | `map(string)` | `{}` | no |
| default\_node\_pool\_availability\_zones | default node pool availability zones | `list(number)` | <pre>[<br>  1,<br>  2,<br>  3<br>]</pre> | no |
| default\_node\_pool\_enable\_auto\_scaling | enable default node pool auto scaling | `bool` | `true` | no |
| default\_node\_pool\_name | default node pool name | `string` | `"default"` | no |
| default\_node\_pool\_node\_count | default node pool node count | `number` | `1` | no |
| default\_node\_pool\_node\_max\_count | enable default node pool auto scaling (only valid with auto scaling) | `number` | `5` | no |
| default\_node\_pool\_node\_min\_count | enable default node pool auto scaling (only valid for auto scaling) | `number` | `1` | no |
| default\_node\_pool\_subnet | name of key from node\_pool\_subnets map to use for default node pool | `string` | `""` | no |
| default\_node\_pool\_vm\_size | default node pool VM size | `string` | `"Standard_D2s_v3"` | no |
| enable\_kube\_dashboard | enable kubernetes dashboard | `bool` | `false` | no |
| enable\_windows\_node\_pools | configure profile for windows node pools (requires windows\_profile\_admin\_username/password) | `bool` | `false` | no |
| identity\_type | ServicePrincipal, SystemAssigned or UserAssigned. | `string` | `"UserAssigned"` | no |
| kubernetes\_version | kubernetes version | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| names | names to be applied to resources | `map(string)` | n/a | yes |
| network\_mode | network mode to br used with Azure CNI | `string` | `"transparent"` | no |
| network\_plugin | network plugin to use for networking (azure or kubenet) | `string` | `"kubenet"` | no |
| network\_profile\_options | docker\_bridge\_cidr, dns\_service\_ip and service\_cidr should all be empty or all should be set | <pre>object({<br>                  docker_bridge_cidr = string<br>                  dns_service_ip     = string<br>                  service_cidr       = string<br>                })</pre> | n/a | yes |
| node\_pool\_subnets | Node pool subnet info. | <pre>map(object({<br>                  id                          = string<br>                  resource_group_name         = string<br>                  network_security_group_name = string<br>                }))</pre> | `{}` | no |
| outbound\_type | outbound (egress) routing method which should be used for this Kubernetes Cluster | `string` | `"loadBalancer"` | no |
| pod\_cidr | used for pod IP addresses | `string` | n/a | yes |
| rbac | role based access control settings | <pre>object({<br>                  enabled        = bool<br>                  ad_integration = bool<br>                })</pre> | <pre>{<br>  "ad_integration": false,<br>  "enabled": true<br>}</pre> | no |
| rbac\_admin\_object\_ids | Admin group object ids for use with rbac active directory integration | `map(string)` | `{}` | no |
| resource\_group\_name | Resource group name | `string` | n/a | yes |
| service\_principal | Service principal information (for use with ServicePrincipal identity\_type). | <pre>object({<br>                  id     = string<br>                  secret = string<br>                  name   = string<br>                })</pre> | n/a | yes |
| subnet\_nsg\_rule\_priority\_start | Starting point for NSG rulee priorities. | `number` | `1000` | no |
| tags | tags to be applied to resources | `map(string)` | n/a | yes |
| use\_service\_principal | use service principal (false will use identity) | `bool` | `false` | no |
| user\_assigned\_identity | User assigned identity for the manged cluster (leave and the module will create one). | <pre>object({<br>                  id           = string<br>                  principal_id = string<br>                  client_id    = string<br>                })</pre> | n/a | yes |
| windows\_profile\_admin\_password | windows profile admin password | `string` | `""` | no |
| windows\_profile\_admin\_username | windows profile admin username | `string` | `"aks-windows-admin"` | no |

## Outputs

| Name | Description |
|------|-------------|
| client\_certificate | kubernetes client certificate |
| client\_key | kubernetes client key |
| cluster\_ca\_certificate | kubernetes cluster ca certificate |
| effective\_outbound\_ips\_ids | The outcome (resource IDs) of the specified arguments. |
| fqdn | kubernetes managed cluster fqdn |
| host | kubernetes host |
| id | kubernetes managed cluster id |
| kube\_config\_raw | raw kubernetes config to be used by kubectl and other compatible tools |
| kubelet\_identity | kubelet identity information |
| name | kubernetes managed cluster name |
| node\_resource\_group | auto-generated resource group which contains the resources for this managed kubernetes cluster |
| password | kubernetes password |
| principal\_id | id of the principal used by this managed kubernetes cluster |
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
  source = "git@github.com:Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
}

# Metadata
module "metadata" {
  source = "git@github.com:Azure-Terraform/terraform-azurerm-metadata.git?ref=v1.0.0"

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
  source = "git@github.com:Azure-Terraform/terraform-azurerm-resource-group.git?ref=v1.0.0"

  location = module.metadata.location
  tags     = module.metadata.tags
  name     = module.metadata.names
}

# AKS
## This will create a managed kubernetes cluster
module "aks" {
  source = "git@github.com:Azure-Terraform/terraform-azurerm-kubernetes.git"

  service_principal_id     = var.service_principal_id
  service_principal_secret = var.service_principal_secret
  service_principal_name   = "service-principal-name"

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

resource "azurerm_kubernetes_cluster_node_pool" "gpu" {
  name                  = "gpu"
  kubernetes_cluster_id = module.aks.id
  vm_size               = "Standard_NC6s_v3"
  availability_zones    = [1,2,3]

  enable_auto_scaling = true
  node_count          = 1
  min_count           = 1
  max_count           = 5

  tags = module.metadata.tags
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
  source = "git@github.com:Azure-Terraform/terraform-azurerm-kubernetes.git/aad-pod-identity"
  
  providers = {
    helm = helm.aks
  }

  resource_group_name    = module.resource_group.name
  service_principal_name = "service-principal-name"

  aad_pod_identity_version = "1.6.0"
}
~~~~

