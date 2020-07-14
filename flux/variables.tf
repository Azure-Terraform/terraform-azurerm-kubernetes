variable "flux_helm_chart_version" {
  description = "version of flux helm chart to use"
  type        = string
  default     = "1.3.0"
}

variable "flux_version" {
  description = "version of flux to install"
  type        = string
  default     = ""
}

variable "ssh_key" {
  description = "key used to access the git repo"
  type        = string
}

variable "git_url" {
  description = "git repo containing flux configuration"
  type        = string
}

variable "git_branch" {
  description = "git branch containing kubernetes manifests"
  type        = string
  default     = "master"
}
