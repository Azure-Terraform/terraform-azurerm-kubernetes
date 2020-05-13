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
| kubernetes\_namespace | namespce in which to install the identity | `string` | `"default"` | no |

## Outputs

No output.
<!--- END_TF_DOCS --->