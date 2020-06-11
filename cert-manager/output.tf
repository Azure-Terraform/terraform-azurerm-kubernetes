output "cluster_issuer_names" {
  value = zipmap(var.domains, formatlist("letsencrypt-acme-%s", var.domains))
}
