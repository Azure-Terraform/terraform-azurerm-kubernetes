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
| helm | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| aad\_pod\_identity\_version | Azure AD pod identity helm chart version | `string` | `"1.6.0"` | no |
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