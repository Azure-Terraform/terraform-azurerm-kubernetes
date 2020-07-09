output "issuers" {
  value      = zipmap(keys(var.issuers), formatlist("letsencrypt-acme-%s", keys(var.issuers)))
  depends_on = [
    # ensure issuers are created before output
    helm_release.issuer
  ]
}

output "namespaces" {
  value = zipmap(keys(var.issuers), [for issuer in keys(var.issuers) : var.issuers[issuer]["namespace"]])
}
