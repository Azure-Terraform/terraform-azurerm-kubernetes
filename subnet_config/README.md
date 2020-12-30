# Azure - Kubernetes Module - Subnet Config

## Introduction

This sub-module configures subnets for use with AKS.
<br />

<!--- BEGIN_TF_DOCS --->
## Providers

| Name | Version |
|------|---------|
| azurerm | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| configure\_network\_role | Add Netowrk Contributor Role for subnet to AKS service principal. | `bool` | n/a | yes |
| configure\_nsg\_rules | Configure subnet NSG rules for AKS. | `bool` | n/a | yes |
| nsg\_rule\_priority\_start | Starting point for NSG rulee priorities. | `number` | n/a | yes |
| principal\_id | Id of principal which manages AKS | `string` | n/a | yes |
| resource\_group\_name | Resource group in which to creat the network security group rules. | `string` | n/a | yes |
| security\_group\_name | Name of security group associated with subnet. | `string` | n/a | yes |
| subnet\_id | Azure virtual network subnet id. | `string` | n/a | yes |

## Outputs

No output.
<!--- END_TF_DOCS --->
