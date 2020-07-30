# Azure - Kubernetes Cert-Manager Module

## Introduction

This module will use install cert-manager into a Kubernetes cluster and configure support for letsencrypt/azuredns.

<br />

<!--- BEGIN_TF_DOCS --->
## Providers

| Name | Version |
|------|---------|
| azurerm | n/a |
| helm | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| additional\_yaml\_config | yaml config for helm chart to be processed last | `string` | `""` | no |
| cert\_manager\_version | cert-manager helm chart version | `string` | `"v0.15.0"` | no |
| create\_kubernetes\_namespace | create kubernetes namespace if not present | `bool` | `true` | no |
| domains | map of domains to domain ids and resource groups which certificates will be generated for | <pre>map(object({<br>                  id             = string # id of dns zone <br>                  resource_group = string # name of resource group containing the dns zone<br>                }))</pre> | `{}` | no |
| helm\_release\_name | helm release name | `string` | `"cert-manager"` | no |
| install\_crds | install cert-manager crds | `bool` | `true` | no |
| issuers | n/a | <pre>map(object({<br>    namespace             = string # kubernetes namespace<br>    cluster_issuer        = bool   # setting 'true' will create a ClusterIssuer, setting 'false' will create a namespace isolated Issuer<br>    email_address         = string # email address used for expiration notification<br>    domain                = string # azuredns hosted domain (must be listed in var.domains)<br>    letsencrypt_endpoint  = string # letsencrypt endpoint (https://letsencrypt.org/docs/acme-protocol-updates).  Allowable inputs are 'staging', 'production' or a full URL<br>  }))</pre> | `{}` | no |
| kubernetes\_namespace | kubernetes namespace | `string` | `"cert-manager"` | no |
| location | Azure Region | `string` | n/a | yes |
| name\_identifier | allows for unique resources when multiple aks cluster exist in same environment | `string` | `""` | no |
| names | names to be applied to resources | `map(string)` | n/a | yes |
| resource\_group\_name | Resource group name | `string` | n/a | yes |
| subscription\_id | Azure Subscription ID | `string` | n/a | yes |
| tags | tags to be applied to resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| issuers | n/a |
| namespaces | n/a |
<!--- END_TF_DOCS --->
