variable "flux_helm_chart_version" {
  description = "version of flux helm chart to use"
  type        = string
  default     = "1.3.0"
}

variable "flux_version" {
  description = "version of flux to install"
  type        = string
  default     = "1.19.0"
}
