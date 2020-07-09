resource "helm_release" "certificate" {
  name             = (var.helm_release_name != "" ? var.helm_release_name : "le-cert-${var.certificate_name}")
  chart            = "${path.module}/chart"
  namespace        = var.namespace
  create_namespace = var.create_namespace

  values= [yamlencode({
    "certificateName" = var.certificate_name
    "namespace"       = var.namespace
    "secretName"      = var.secret_name
    "issuerRefName"   = var.issuer_ref_name
    "dnsNames"        = jsonencode(var.dns_names)
  })]

}
