output "issuers" {
  value = zipmap(keys(var.issuers), formatlist("letsencrypt-acme-%s", keys(var.issuers)))
}

output "namespaces" {
  value = zipmap(keys(var.issuers), [for issuer in keys(var.issuers) : var.issuers[issuer]["namespace"]])
}
