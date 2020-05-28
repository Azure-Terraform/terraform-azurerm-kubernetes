#resource "helm_release" "cert_manager" {
#  name             = "cert-manager"
#  namespace        = "cert-manager"
#  create_namespace = true
#  repository       = "https://charts.jetstack.io"
#  chart            = "cert-manager"
#  version          = var.cert_manager_version
#
#  set {
#    name  = "installCRDs"
#    value = "true"
#  }
#}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_dns_zone" "zone" {
  count               = length(var.domains)
  name                = var.domains[count.index]
  #resource_group_name = "search-service"
}

resource "azurerm_user_assigned_identity" "cert_manager" {
  name                 = "${var.names.product_group}-${var.names.subscription_type}-certmgr"
  location             = var.location
  resource_group_name  = var.resource_group_name
  tags                 = var.tags
}

resource "azurerm_role_definition" "cert_manager" {
  count       = (length(var.domains) > 0 ? 1 : 0)
  name        = "${var.names.product_group}-${var.names.subscription_type}-certmgr"
  scope       = data.azurerm_resource_group.rg.id
  description = "Allow cert manager to use TXT entries for verification"

  permissions {
    actions     = ["Microsoft.Network/dnszones/TXT/read",
                   "Microsoft.Network/dnszones/TXT/write",
                   "Microsoft.Network/dnszones/TXT/delete"]
    not_actions = []
  }

  assignable_scopes = data.azurerm_dns_zone.zone.*.id
}