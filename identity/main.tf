provider "helm" {
  kubernetes {
    host                   = var.kubectl_host
    client_certificate     = base64decode(var.kubectl_client_certificate)
    client_key             = base64decode(var.kubectl_client_key)
    cluster_ca_certificate = base64decode(var.kubectl_cluster_ca_certificate)
  }
}

resource "helm_release" "vault_init_identity" {
  name       = (var.helm_name != "" ? var.helm_name : "pod-id-${var.identity_name}")
  chart      = "${path.module}/chart"

  namespace  = var.namespace

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
