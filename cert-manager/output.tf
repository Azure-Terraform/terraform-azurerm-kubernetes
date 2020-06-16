output "issuers" {
  value = zipmap(keys(var.issuers), formatlist("letsencrypt-acme-%s", keys(var.issuers)))
}