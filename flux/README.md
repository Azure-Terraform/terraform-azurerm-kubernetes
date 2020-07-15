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

## Outputs

No output.
<!--- END_TF_DOCS --->
## Example

~~~~
module "flux" {
  source = "github.com/Azure-Terraform/terraform-azurerm-kubernetes.git//flux"

  providers = {helm = helm.aks, kubernetes = kubernetes.aks}

  flux_helm_chart_version = "1.4.0"

  config_repo_ssh_key = tls_private_key.config.private_key_pem
  config_repo_url     = "git@github.com:org/flux.git"
  config_repo_path    = "aks"

  default_ssh_key = tls_private_key.default.private_key_pem
}
~~~~
