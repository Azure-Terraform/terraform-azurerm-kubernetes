# Azure - Kubernetes AAD Pod Identity Module

## Introduction

This module will enable aad pod identity within a managed Kubernetes cluster hosted on Azure Kubernetes Service.
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
| additional\_scopes | identity scopes residing outside of AKS MC\_resource\_group (resource group id or identity id would be a common input) | `list(string)` | `[]` | no |
| helm\_chart\_version | Azure AD pod identity helm chart version | `string` | `"2.0.0"` | no |
| node\_resource\_group\_name | AKS node resource group name | `string` | n/a | yes |
| principal\_id | AKS principal id | `string` | n/a | yes |

## Outputs

No output.
<!--- END_TF_DOCS --->
