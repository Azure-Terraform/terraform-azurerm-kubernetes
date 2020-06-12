# Azure - Kubernetes Cert-Manager Certificate Module

## Introduction

This module will use cert-manager to create Let's Encrypt certificate and Kubernetes secret.

<br />

<!--- BEGIN_TF_DOCS --->
## Providers

| Name | Version |
|------|---------|
| helm | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| certificate\_name | name of certificate | `string` | n/a | yes |
| dns\_names | dns name(s) for certificate | `list(string)` | n/a | yes |
| helm\_release\_name | name for helm release (defauls to le-cert-<certificate\_name>) | `string` | `""` | no |
| issuer\_ref\_name | name of kubernetes cluster issuer | `string` | n/a | yes |
| namespace | kubernetes namespace | `string` | `"default"` | no |
| secret\_name | name of kubernetes secret | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| certificate\_name | n/a |
| helm\_release\_name | n/a |
| issuer\_ref\_name | n/a |
| namespace | n/a |
| secret\_name | n/a |
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

  kubernetes_version = "1.16.8"

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

module "dns" {
  source = "github.com/Azure-Terraform/terraform-azurerm-dns-zone.git"

  domain_prefix = "application.eastus2"

  iog_resource_group_name = "rg-iog-sandbox-eastus2-contoso"
  iog_subscription_id     = "00000000-0000-0000-0000-000000000000"
  sre_resource_group_name = module.resource_group.name
  sre_subscription_id     = module.subscription.output.subscription_id

  names               = module.metadata.names
  tags                = module.metadata.tags
}

module "cert_manager" {
  source    = "git::https://github.com/Azure-Terraform/terraform-azurerm-kubernetes.git//cert-manager?ref=v1.1.0"
  providers = { helm = helm.aks }

  subscription_id = module.subscription.output.subscription_id

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  names = module.metadata.names
  tags  = module.metadata.tags

  domains = [module.dns.name]

}

module "wildcard_certificate" {
  source    = "git::https://github.com/Azure-Terraform/terraform-azurerm-kubernetes.git//cert-manager/certificate?ref=v1.1.0"
  providers = { helm = helm.aks }

  certificate_name = "tf-cert-wildcard"
  namespace = "demo"
  secret_name = "tf-secret"
  issuer_ref_name = module.cert_manager.cluster_issuer_names[module.dns.name]

  dns_names = ["*.${module.dns.name"]
}
~~~~
