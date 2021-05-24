terraform {
  required_version = ">= 0.14.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.57.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 1.2.0"
    }
  }
}
