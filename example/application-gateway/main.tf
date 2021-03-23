terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.51.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=2.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=2.0.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "=2.0.3"
    }
  }
  required_version = "=0.14.7"
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = module.kubernetes.kube_config.host
  client_certificate     = base64decode(module.kubernetes.kube_config.client_certificate)
  client_key             = base64decode(module.kubernetes.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.kubernetes.kube_config.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.kubernetes.kube_config.host
    client_certificate     = base64decode(module.kubernetes.kube_config.client_certificate)
    client_key             = base64decode(module.kubernetes.kube_config.client_key)
    cluster_ca_certificate = base64decode(module.kubernetes.kube_config.cluster_ca_certificate)
  }
}

data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "azurerm_subscription" "current" {
}

resource "random_string" "random" {
  length  = 12
  upper   = false
  number  = false
  special = false
}

resource "random_password" "admin" {
  length  = 14
  special = true
}

module "subscription" {
  source          = "github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

module "naming" {
  source = "github.com/LexisNexis-RBA/terraform-azurerm-naming.git?ref=v1.0.9"
}

module "metadata" {
  source = "github.com/Azure-Terraform/terraform-azurerm-metadata.git?ref=v1.5.0"

  naming_rules = module.naming.yaml

  market              = "us"
  project             = "https://github.com/Azure-Terraform/terraform-azurerm-kubernetes/tree/master/example/mixed-arch"
  location            = "eastus2"
  environment         = "sandbox"
  product_name        = random_string.random.result
  business_unit       = "businesssvc"
  product_group       = "contoso"
  subscription_id     = module.subscription.output.subscription_id
  subscription_type   = "dev"
  resource_group_type = "app"
}

module "resource_group" {
  source = "github.com/Azure-Terraform/terraform-azurerm-resource-group.git?ref=v1.0.0"

  location = module.metadata.location
  names    = module.metadata.names
  tags     = module.metadata.tags
}

module "virtual_network" {
  source = "github.com/Azure-Terraform/terraform-azurerm-virtual-network.git?ref=v2.5.1"

  naming_rules = module.naming.yaml

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  names               = module.metadata.names
  tags                = module.metadata.tags

  address_space = ["10.1.0.0/22"]

  subnets = {
    "iaas-private" = { cidrs = ["10.1.0.0/24"] }
    "iaas-public" = { cidrs = ["10.1.1.0/24"]
      allow_lb_inbound        = true # Allow traffic from Azure Load Balancer to pods
      allow_internet_outbound = true # Allow traffic to Internet for image download
    }
  }

  route_tables = {
    default = {
      disable_bgp_route_propagation = true
      routes = {
        internet = {
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "Internet"
        }
        internal-1 = {
          address_prefix         = "10.0.0.0/8"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.0.0.0"
        }
        internal-2 = {
          address_prefix         = "172.16.0.0/12"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.0.0.0"
        }
        internal-3 = {
          address_prefix         = "192.168.0.0/16"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.0.0.0"
        }
        local-vnet = {
          address_prefix = "10.1.1.0/24"
          next_hop_type  = "vnetlocal"
        }
      }
    }
  }


  module "kubernetes" {
    source = "github.com/Azure-Terraform/terraform-azurerm-kubernetes.git"

    location            = module.metadata.location
    names               = module.metadata.names
    tags                = module.metadata.tags
    resource_group_name = module.resource_group.name

    identity_type = "UserAssigned"

    user_assigned_identity = {
      id           = "module.kubernetes.kubelet_identity.user_assigned_identity_id"
      principal_id = "module.kubernetes.principal_id"
      client_id    = "module.kubernetes.kubelet_identity.client_id"
    }

    rbac = {
      enabled        = true
      ad_integration = true
    }

    rbac_admin_object_ids = {
      rbac_admin_object_ids = user_name_object_id
    }

    windows_profile = {
      admin_username = "azadmin"
      admin_password = random_password.admin.result
    }

    kubernetes_version         = "1.19.7"
    network_plugin             = "azure"
    configure_network_role     = true
    configure_subnet_nsg_rules = true
    enable_kube_dashboard      = false

    acr_pull_access = { "sre-registry" = "/subscriptions/32496c5b-1147-452c-8469-3a11028f8946/resourceGroups/sre_container_registry/providers/Microsoft.ContainerRegistry/registries/srecontainerregistry" }

    default_node_pool = "system"

    node_pools = {
      system = {
        subnet = "private"
      }
      linuxweb = {
        os_type             = "Linux"
        vm_size             = "Standard_B2s"
        enable_auto_scaling = true
        min_count           = 1
        max_count           = 3
        availability_zones  = [1, 2, 3]
        subnet              = "public"
      }
      winweb = {
        os_type             = "Windows"
        vm_size             = "Standard_B2s"
        enable_auto_scaling = true
        min_count           = 1
        max_count           = 3
        availability_zones  = [1, 2, 3]
        subnet              = "public"
      }
    }

    node_pool_subnets = {
      private = {
        id                          = module.virtual_network.subnets["iaas-private"].id
        resource_group_name         = module.virtual_network.subnets["iaas-private"].resource_group_name
        network_security_group_name = module.virtual_network.subnets["iaas-private"].network_security_group_name
      }
      public = {
        id                          = module.virtual_network.subnets["iaas-public"].id
        resource_group_name         = module.virtual_network.subnets["iaas-public"].resource_group_name
        network_security_group_name = module.virtual_network.subnets["iaas-public"].network_security_group_name
      }
    }
  }
}

resource "azurerm_network_security_rule" "ingress_public_allow_nginx" {
  name                        = "AllowNginx"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = data.kubernetes_service.nginx.status.0.load_balancer.0.ingress.0.ip
  resource_group_name         = module.virtual_network.subnets["iaas-public"].resource_group_name
  network_security_group_name = module.virtual_network.subnets["iaas-public"].network_security_group_name
}

resource "azurerm_network_security_rule" "ingress_public_allow_iis" {
  name                        = "AllowIIS"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = data.kubernetes_service.iis.status.0.load_balancer.0.ingress.0.ip
  resource_group_name         = module.virtual_network.subnets["iaas-public"].resource_group_name
  network_security_group_name = module.virtual_network.subnets["iaas-public"].network_security_group_name
}

resource "helm_release" "nginx" {
  depends_on = [module.kubernetes]
  name       = "nginx"
  chart      = "./helm_chart"

  set {
    name  = "name"
    value = "nginx"
  }

  set {
    name  = "image"
    value = "nginx:latest"
  }

  set {
    name  = "nodeSelector"
    value = yamlencode({ agentpool = "linuxweb" })
  }
}

resource "helm_release" "iis" {
  depends_on = [module.kubernetes]
  name       = "iis"
  chart      = "./helm_chart"
  timeout    = 600

  set {
    name  = "name"
    value = "iis"
  }

  set {
    name  = "image"
    value = "microsoft/iis:latest"
  }

  set {
    name  = "nodeSelector"
    value = yamlencode({ agentpool = "winweb" })
  }
}

data "kubernetes_service" "nginx" {
  depends_on = [helm_release.nginx]
  metadata {
    name = "nginx"
  }
}

data "kubernetes_service" "iis" {
  depends_on = [helm_release.iis]
  metadata {
    name = "iis"
  }
}

#######################
# Application Gateway #
#######################

resource "azurerm_public_ip" "appgw" {
  name                = "${module.resource_group.name}-pip"
  resource_group_name = module.resource_group.name
  location            = module.metadata.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "network" {
  name                = "${module.resource_group.name}-appgw"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "${module.resource_group.name}-appgw-ip-config"
    subnet_id = module.virtual_network.subnets["iaas-public"].id
  }

  frontend_port {
    name = "${module.resource_group.name}-appgw-frontend"
    port = 80
  }

  frontend_port {
    name = "${module.resource_group.name}-appgw-frontend-https"
    port = 443
  }


  frontend_ip_configuration {
    name                 = "${module.resource_group.name}-appgw-frontend-config"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  backend_address_pool {
    name = "${module.resource_group.name}-appgw-pool"
  }

  backend_http_settings {
    name                  = "${module.resource_group.name}-appgw-settings-default"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  request_routing_rule {
    name                       = "${module.resource_group.name}-rqrt"
    rule_type                  = "Basic"
    http_listener_name         = "${module.resource_group.name}-appgw-frontend-listener"
    backend_address_pool_name  = "${module.resource_group.name}-appgw-pool"
    backend_http_settings_name = "${module.resource_group.name}-appgw-settings-default"
  }

  http_listener {
    name                           = "${module.resource_group.name}-appgw-frontend-listener"
    frontend_ip_configuration_name = "${module.resource_group.name}-appgw-frontend-config"
    frontend_port_name             = "${module.resource_group.name}-appgw-frontend"
    protocol                       = "Http"
  }

  # Ignore changes by Kubernetes (AGIC)
  lifecycle {
    ignore_changes = [
      tags,
      ssl_certificate,
      trusted_root_certificate,
      frontend_port,
      backend_address_pool,
      backend_http_settings,
      http_listener,
      url_path_map,
      request_routing_rule,
      probe,
      redirect_configuration,
      ssl_policy,
    ]
  }

}

# Managed Identity
resource "azurerm_user_assigned_identity" "ingress" {
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  name = "${module.resource_group.name}-mi"
}

# Role Assignments
resource "azurerm_role_assignment" "ra1" {
  scope                = module.virtual_network.subnets["iaas-public"].id
  role_definition_name = "Network Contributor"
  principal_id         = module.kubernetes.principal_id
  depends_on           = [module.kubernetes]
}

resource "azurerm_role_assignment" "ra2" {
  scope                = module.kubernetes.kubelet_identity.user_assigned_identity_id
  role_definition_name = "Managed Identity Operator"
  principal_id         = module.kubernetes.principal_id
  depends_on           = [module.kubernetes]
}

resource "azurerm_role_assignment" "ra3" {
  scope                = azurerm_application_gateway.network.id
  role_definition_name = "Contributor"
  principal_id         = module.kubernetes.principal_id
  depends_on           = [module.kubernetes, azurerm_application_gateway.network]
}

resource "azurerm_role_assignment" "ra4" {
  scope                = module.resource_group.id
  role_definition_name = "Reader"
  principal_id         = module.kubernetes.principal_id
  depends_on           = [module.kubernetes]
}

# Ingress Helm
data "helm_repository" "azure-ingress" {
  name = "application-gateway-kubernetes-ingress"
  url  = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"
}

resource "helm_release" "ingress" {
  provider = helm.aks

  name       = "ingress-azure"
  namespace  = "default"
  repository = data.helm_repository.azure-ingress.metadata[0].name
  chart      = "ingress-azure"
  version    = "1.2.0"

  set {
    name  = "appgw.subscriptionId"
    value = module.subscription.output.subscription_id
  }

  set {
    name  = "appgw.resourceGroup"
    value = module.resource_group.name
  }

  set {
    name  = "appgw.name"
    value = "${module.resource_group.name}-appgw"
  }

  set {
    name  = "rbac.enabled"
    value = true
  }

  set {
    name  = "armAuth.type"
    value = "aadPodIdentity"
  }

  set {
    name  = "armAuth.identityResourceID"
    value = module.kubernetes.kubelet_identity.user_assigned_identity_id
  }

  set {
    name  = "armAuth.identityClientID"
    value = azurerm_user_assigned_identity.ingress.client_id
  }

  depends_on = [module.aad_pod_identity, azurerm_application_gateway.network]
}

##############
# App Deploy #
##############

# Pod
resource "kubernetes_pod" "helloworld" {
  metadata {
    name = "helloworld"
    labels = {
      app = "helloworld"
    }
  }

  spec {
    container {
      image = "xhissy/helloworld-php:v1.0.0"
      name  = "helloworld"

      port {
        container_port = 80
      }

      port {
        container_port = 81
      }
    }
  }
}

# Service
resource "kubernetes_service" "helloworld" {

  metadata {
    name = "helloworld-service"
    labels = {
      app = "helloworld"
    }
  }

  spec {
    selector = {
      app = "helloworld"
    }
    port {
      port        = 80
      target_port = 80
    }
  }

}

resource "kubernetes_service" "helloworld-81" {

  metadata {
    name = "helloworld-service-81"
    labels = {
      app = "helloworld"
    }
  }

  spec {
    selector = {
      app = "helloworld"
    }
    port {
      port        = 80
      target_port = 80
    }
  }

}

# Ingress
resource "kubernetes_ingress" "helloworld" {
  metadata {
    name = "helloworld-ingress"
    annotations = {
      "kubernetes.io/ingress.class"                     = "azure/application-gateway"
      "appgw.ingress.kubernetes.io/backend-path-prefix" = "/"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/"
          backend {
            service_name = "helloworld-service"
            service_port = "80"
          }
        }

        path {
          path = "/WsMarketing"
          backend {
            service_name = "helloworld-service-81"
            service_port = "80"
          }
        }
      }
    }
  }
}

output "nginx_url" {
  value = "http://${data.kubernetes_service.nginx.status.0.load_balancer.0.ingress.0.ip}"
}

output "iis_url" {
  value = "http://${data.kubernetes_service.iis.status.0.load_balancer.0.ingress.0.ip}"
}

output "aks_login" {
  value = "az aks get-credentials --name ${module.kubernetes.name} --resource-group ${module.resource_group.name}"
}

output "aks_browse" {
  value = "az aks browse --name ${module.kubernetes.name} --resource-group ${module.resource_group.name}"
}
