variable "certificate_name" {
  description = "name of certificate"
  type        = string
  default     = "letsencrypt-certificate-"
}

variable "identity_name" {
  description = "name for Azure identity to be used by AAD"
  type        = string
}


variable "identity_client_id" {
  description = "client id of the managed identity"
  type        = string
}

variable "identity_resource_id" {
  description = "resource id of the managed identity"
  type        = string
}
