# Azure - Kubernetes Module - Subnet Config

## Introduction

This sub-module configures subnets for use with AKS.
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
| aks\_managed\_vnet | use AKS managed vnet/subnets (false requires default\_node\_pool\_vnet\_subnet\_id is specified) | `bool` | `true` | no |
| default\_node\_pool\_availability\_zones | default node pool availability zones | `list(number)` | <pre>[<br>  1,<br>  2,<br>  3<br>]</pre> | no |
| default\_node\_pool\_enable\_auto\_scaling | enable default node pool auto scaling | `bool` | `true` | no |
| default\_node\_pool\_name | default node pool name | `string` | `"default"` | no |
| default\_node\_pool\_node\_count | default node pool node count | `number` | `1` | no |
| default\_node\_pool\_node\_max\_count | enable default node pool auto scaling (only valid with auto scaling) | `number` | `5` | no |
| default\_node\_pool\_node\_min\_count | enable default node pool auto scaling (only valid for auto scaling) | `number` | `1` | no |
| default\_node\_pool\_subnet | default node pool vnet subnet info | <pre>object({<br>                  id                  = string<br>                  resource_group_name = string<br>                  security_group_name = string<br>                })</pre> | <pre>{<br>  "id": "",<br>  "resource_group_name": "",<br>  "security_group_name": ""<br>}</pre> | no |
| default\_node\_pool\_vm\_size | default node pool VM size | `string` | `"Standard_D2s_v3"` | no |
| enable\_aad\_pod\_identity | enable Azure AD pod identity enable kubernetes dashboard | `bool` | `true` | no |
| enable\_kube\_dashboard | enable kubernetes dashboard | `bool` | `true` | no |
| enable\_windows\_node\_pools | configure profile for windows node pools (requires windows\_profile\_admin\_username/password) | `bool` | `false` | no |
| kubernetes\_version | kubernetes version | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| names | names to be applied to resources | `map(string)` | n/a | yes |
| network\_plugin | network plugin to use for networking (azure or kubenet) | `string` | `"kubenet"` | no |
| resource\_group\_name | Resource group name | `string` | n/a | yes |
| service\_principal\_id | Azure Service Principal ID | `string` | `""` | no |
| service\_principal\_name | Azure Service Principal Name | `string` | `""` | no |
| service\_principal\_secret | Azure Service Principal Secret | `string` | `""` | no |
| tags | tags to be applied to resources | `map(string)` | n/a | yes |
| use\_service\_principal | use service principal (false will use SystemAssigned identity) | `bool` | `false` | no |
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
| name | kubernetes managed cluster name |
| node\_resource\_group | auto-generated resource group which contains the resources for this managed kubernetes cluster |
| password | kubernetes password |
| principal\_id | id of the principal used by this managed kubernetes cluster |
| username | kubernetes username |
<!--- END_TF_DOCS --->
