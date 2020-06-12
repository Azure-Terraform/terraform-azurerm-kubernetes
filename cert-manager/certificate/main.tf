resource "helm_release" "certificate" {
  name       = (var.helm_name != "" ? var.helm_name : "pod-id-${var.identity_name}")
  chart      = "${path.module}/chart"

  set {
    name  = "azureIdentity.name"
    value = var.identity_name
  }

  set {
    name  = "azureIdentity.resourceID"
    value = var.identity_resource_id
  }

  set {
    name  = "azureIdentity.clientID"
    value = var.identity_client_id
  }

  set {
    name  = "azureIdentityBinding.name"
    value = "${var.identity_name}-binding"
  }

  set {
    name  = "azureIdentityBinding.selector"
    value = var.identity_name
  }

}

certificateName:
namespace:
secretName:
issuerRefName:
dnsNames:

chomp(yamlencode(var.kubernetes_node_selector)
