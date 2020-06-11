resource "helm_release" "nginx_ingress" {
  name       = var.helm_release_name
  repository = var.helm_repository
  chart      = "nginx-ingress"
  version    = var.helm_chart_version
  namespace  = var.kubernetes_namespace

  create_namespace = var.kubernetes_create_namespace

  values = [
    templatefile("${path.module}/config/nginx_ingress_config.yaml.tmpl", {
      ip_address = var.load_balancer_ip
    }),
    var.additional_yaml_config
  ]
}
