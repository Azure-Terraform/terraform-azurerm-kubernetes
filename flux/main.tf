resource "helm_release" "flux" {
  namespace        = "flux"
  create_namespace = true

  vaules = [
    templatefile("${path.module}/config/flux_config.yaml.tmpl", {
      
