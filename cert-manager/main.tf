data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_dns_zone" "zone" {
  count               = length(var.domains)
  name                = var.domains[count.index]
  resource_group_name = var.resource_group_name
}

resource "azurerm_user_assigned_identity" "cert_manager" {
  name                 = "${var.names.product_group}-${var.names.subscription_type}-certmgr"
  location             = var.location
  resource_group_name  = var.resource_group_name
  tags                 = var.tags
}

resource "azurerm_role_definition" "cert_manager" {
  count       = length(var.domains)
  name        = "${var.names.product_group}-${var.names.subscription_type}-certmgr-${var.domains[count.index]}"
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
  count              = length(var.domains)
  scope              = data.azurerm_dns_zone.zone.*.id[count.index]
  role_definition_id = azurerm_role_definition.cert_manager.*.id[count.index]
  principal_id       = azurerm_user_assigned_identity.cert_manager.principal_id
}

module "identity" {
  source = "github.com/Azure-Terraform/terraform-azurerm-kubernetes.git//aad-pod-identity/identity?ref=v1.0.0"

  identity_name        = azurerm_user_assigned_identity.cert_manager.name
  identity_client_id   = azurerm_user_assigned_identity.cert_manager.client_id
  identity_resource_id = azurerm_user_assigned_identity.cert_manager.id
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_version

  values = [
    yamlencode({
      installCRDs = "true"
      podLabels = {
        aadpodidbinding = "${azurerm_user_assigned_identity.cert_manager.name}"
      }
    }
    )
  ]
}

resource "helm_release" "cluster_issuer" {
  count            = length(var.domains)
  name             = "cert-manager-ci-${var.domains[count.index]}"
  namespace        = "cert-manager"
  chart            = "${path.module}/charts/letsencrypt-acme"

  values = [
    yamlencode({
      name           = "letsencrypt-acme-${var.domains[count.index]}"
      email          = "tim.miller@lexisnexisrisk.com"
      server         = "https://acme-staging-v02.api.letsencrypt.org/directory"
      secretName     = "secret-${var.domains[count.index]}"
      subscriptionID = var.subscription_id
      resourceGroup  = var.resource_group_name
      dnsZone        = "${var.domains[count.index]}"
    }
    )
  ]
}