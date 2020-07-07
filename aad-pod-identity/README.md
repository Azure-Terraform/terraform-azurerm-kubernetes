# Azure - Kubernetes AAD Pod Identity Module

## Introduction

This module will enable aad pod identity within a managed Kubernetes cluster hosted on Azure Kubernetes Service.
<br />

<!--- BEGIN_TF_DOCS --->
## Providers

| Name | Version |
|------|---------|
| azuread | n/a |
| azurerm | n/a |
| helm | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| aad\_pod\_identity\_version | Azure AD pod identity helm chart version | `string` | `"1.6.0"` | no |
| resource\_group\_name | Resource group name | `string` | n/a | yes |
| service\_principal\_name | Azure Service Principal Name | `string` | n/a | yes |

## Outputs

No output.
<!--- END_TF_DOCS --->
