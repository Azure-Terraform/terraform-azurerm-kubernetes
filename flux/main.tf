resource "kubernetes_namespace" "fluxcd" {
  metadata {
    name = "fluxcd"
  }
}

resource "kubernetes_secret" "config_repo_ssh_key" {
  depends_on = [kubernetes_namespace.fluxcd]

  metadata {
    namespace = "fluxcd"
    name      = "flux-ssh"
  }
  data = {
    identity = var.config_repo_ssh_key
  }
}

resource "kubernetes_secret" "reference_repo_ssh_key" {
  depends_on = [kubernetes_namespace.fluxcd]

  metadata {
    namespace = "fluxcd"
    name      = "flux-ssh-reference"
  }
  data = {
    identity = var.reference_repo_ssh_key
  }
}

data "external" "ssh_host_key" {
  program = ["sh", "${path.module}/ssh_host_key.sh"]

  query = {
    host = var.config_repo_url
  }
}

resource "helm_release" "flux" {
  depends_on = [kubernetes_secret.ssh_key]

  name             = "flux"
  namespace        = "fluxcd"
  #create_namespace = true

  repository = "https://charts.fluxcd.io"
  chart      = "flux"
  version    = var.flux_helm_chart_version

  values = [
    templatefile("${path.module}/config.yaml.tmpl", {
      flux_version       = var.flux_version
      config_repo_url    = var.config_repo_url
      config_repo_branch = var.config_repo_branch
      config_repo_path   = var.config_repo_path
      ssh_host_key       = data.external.ssh_host_key.result["key"]
    }),
    var.additional_yaml_config
  ]
}
