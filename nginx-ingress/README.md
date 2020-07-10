# Azure - Kubernetes NGINX ingress Module

## Introduction

This module will install an NGINX ingress module into an AKS cluster.  This is largely to bridge the gap between AzureDNS/Azure Static IP/AKS.
<br />

<!--- BEGIN_TF_DOCS --->
## Providers

| Name | Version |
|------|---------|
| helm | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| additional\_yaml\_config | yaml config for helm chart to be processed last | `string` | `""` | no |
| helm\_chart\_version | helm chart version | `string` | `"1.39.0"` | no |
| helm\_release\_name | helm release name | `string` | n/a | yes |
| helm\_repository | nginx-ingress helm repository url | `string` | `"https://kubernetes-charts.storage.googleapis.com"` | no |
| kubernetes\_create\_namespace | create kubernetes namespace | `bool` | `true` | no |
| kubernetes\_namespace | kubernetes\_namespace | `string` | `"default"` | no |
| load\_balancer\_ip | loadBalancerIP | `string` | n/a | yes |

## Outputs

No output.
<!--- END_TF_DOCS --->
