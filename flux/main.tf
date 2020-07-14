resource "kubernetes_namespace" "fluxcd" {
  metadata {
    name = "fluxcd"
  }
}

resource "kubernetes_secret" "ssh_key" {
  depends_on = [kubernetes_namespace.fluxcd]

  metadata {
    namespace = "fluxcd"
    name      = "ssh-key"
  }
  data = {
    ssh_key = var.ssh_key
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

  #var.ssh_key

  set {
    name  = "image.version"
    value = var.flux_version
  }

  set {
    name  = "git.url"
    value = var.git_url
  }

  set {
    name  = "git.branch"
    value = var.git_branch
  }

  set {
    name  = "git.secretName"
    value = "ssh-key"
  }
}
