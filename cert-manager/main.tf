data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_dns_zone" "zone" {
  for_each            = var.domains
  name                = each.key
  resource_group_name = var.resource_group_name
}

resource "azurerm_user_assigned_identity" "cert_manager" {
  name                 = "${var.names.product_group}-${var.names.subscription_type}-certmgr${local.delimiter}${var.name_identifier}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  tags                 = var.tags
}

resource "azurerm_role_definition" "cert_manager" {
  for_each    = var.domains
  name        = "${var.names.product_group}-${var.names.subscription_type}-certmgr${local.delimiter}${var.name_identifier}-${each.key}"
  description = "Allow cert manager to use TXT entries for verification"
  scope       = data.azurerm_resource_group.rg.id

  permissions {
    actions     = ["Microsoft.Network/dnszones/TXT/read",
                   "Microsoft.Network/dnszones/TXT/write",
                   "Microsoft.Network/dnszones/TXT/delete"]
    not_actions = []
  }

  assignable_scopes = [data.azurerm_resource_group.rg.id]
}

resource "azurerm_role_assignment" "cert_manager" {
  for_each           = var.domains
  scope              = data.azurerm_dns_zone.zone[each.key].id
  role_definition_id = azurerm_role_definition.cert_manager[each.key].id
  principal_id       = azurerm_user_assigned_identity.cert_manager.principal_id
}

module "identity" {
  source = "github.com/Azure-Terraform/terraform-azurerm-kubernetes.git//aad-pod-identity/identity?ref=v1.0.0"

  identity_name        = azurerm_user_assigned_identity.cert_manager.name
  identity_client_id   = azurerm_user_assigned_identity.cert_manager.client_id
  identity_resource_id = azurerm_user_assigned_identity.cert_manager.id
}

resource "helm_release" "cert_manager" {
  name             = var.helm_release_name
  namespace        = var.kubernetes_namespace
  create_namespace = var.create_kubernetes_namespace
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_version

  values = [
    yamlencode({
      installCRDs = "${var.install_crds}"
      podLabels = {
        aadpodidbinding = "${azurerm_user_assigned_identity.cert_manager.name}"
      }
      podDnsPolicy = "None"
      podDnsConfig = {
        nameservers = ["8.8.8.8","8.8.4.4"]
      }
      extraArgs	= ["--enable-certificate-owner-ref=true"]
    }),
    var.additional_yaml_config
  ]
}

resource "helm_release" issuer {
  depends_on       = [helm_release.cert_manager]
  for_each         = var.issuers

  name      = "cert-manager-issuer-${each.key}"
  namespace = each.value.namespace
  chart     = "${path.module}/charts/letsencrypt-acme"

  values = [
    yamlencode({
      kind           = (each.value.cluster_issuer ? "ClusterIssuer" : "Issuer")
      name           = "letsencrypt-acme-${each.key}"
      email          = each.value.email_address
      server         = lookup(local.le_endpoint, each.value.letsencrypt_endpoint, each.value.letsencrypt_endpoint)
      secretName     = "cert-manager-issuer-${each.key}"
      subscriptionID = var.subscription_id
      resourceGroup  = var.resource_group_name
      dnsZone        = each.value.domain
    }
    )
  ]

}