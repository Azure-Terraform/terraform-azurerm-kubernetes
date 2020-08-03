# Azure - Kubernetes Flux Module

## Introduction

This module will enable flux within a managed Kubernetes cluster hosted on Azure Kubernetes Service.
<br />

<!--- BEGIN_TF_DOCS --->
## Providers

| Name | Version |
|------|---------|
| external | n/a |
| helm | n/a |
| kubernetes | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| additional\_yaml\_config | yaml config for helm chart to be processed last | `string` | `""` | no |
| config\_repo\_branch | git branch containing kubernetes manifests | `string` | `"master"` | no |
| config\_repo\_path | path in repo containing flux configuration | `string` | `""` | no |
| config\_repo\_ssh\_key | key used to access the config git repo | `string` | n/a | yes |
| config\_repo\_url | git repo containing flux configuration | `string` | n/a | yes |
| default\_ssh\_key | default key used to access git repos | `string` | n/a | yes |
| flux\_helm\_chart\_version | version of flux helm chart to use | `string` | `"1.4.0"` | no |
| flux\_version | version of flux to install | `string` | `""` | no |
| helm\_operator\_crd\_version | version of helm-operator CRDs to install | `string` | `"1.1.0"` | no |

## Outputs

No output.
<!--- END_TF_DOCS --->
