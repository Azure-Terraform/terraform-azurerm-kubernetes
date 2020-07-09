# Azure - Kubernetes Cert-Manager Certificate Module

## Introduction

This module will use cert-manager to create Let's Encrypt certificate and Kubernetes secret.

<br />

<!--- BEGIN_TF_DOCS --->
## Providers

| Name | Version |
|------|---------|
| helm | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| certificate\_name | name of certificate | `string` | n/a | yes |
| create\_namespace | create kubernetes namespace | `bool` | `true` | no |
| dns\_names | dns name(s) for certificate | `list(string)` | n/a | yes |
| helm\_release\_name | name for helm release (defauls to le-cert-<certificate\_name>) | `string` | `""` | no |
| issuer\_ref\_name | name of kubernetes cluster issuer | `string` | n/a | yes |
| namespace | kubernetes namespace | `string` | `"default"` | no |
| secret\_name | name of kubernetes secret | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| certificate\_name | n/a |
| helm\_release\_name | n/a |
| issuer\_ref\_name | n/a |
| namespace | n/a |
| secret\_name | n/a |
| secret\_path | n/a |
<!--- END_TF_DOCS --->
