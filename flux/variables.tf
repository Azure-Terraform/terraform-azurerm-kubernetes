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

variable "config_repo_ssh_key" {
  description = "key used to access the git repo"
  type        = string
}

variable "config_repo_url" {
  description = "git repo containing flux configuration"
  type        = string
}

variable "config_repo_path" {
  description = "path in repo containing flux configuration"
  type        = string
  default     = ""
}

variable "config_repo_branch" {
  description = "git branch containing kubernetes manifests"
  type        = string
  default     = "master"
}

variable "reference_repo_ssh_key" {
  description = "key used to access the git repo"
  type        = string
}

variable "additional_yaml_config" {
  description = "yaml config for helm chart to be processed last"
  type        = string
  default     = ""
}
