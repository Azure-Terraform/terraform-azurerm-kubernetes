output "helm_release_name" {
  value = (var.helm_release_name != "" ? var.helm_release_name : "le-cert-${var.certificate_name}")
}

output "certificate_name" {
  value = var.certificate_name
}

output "namespace" {
  value = var.namespace
}

output "secret_name" {
  value = var.secret_name
}

output "secret_path" {
  value = "${var.namespace}/${var.secret_name}"
}

output "issuer_ref_name" {
  value = var.issuer_ref_name
}
