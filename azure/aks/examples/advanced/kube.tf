provider "kubernetes" {
  host                   = module.aks.host
  cluster_ca_certificate = module.aks.ca_certificate
  client_certificate     = module.aks.client_certificate
  client_key             = module.aks.client_key
}

provider "helm" {
  kubernetes {
    host                   = module.aks.host
    cluster_ca_certificate = module.aks.ca_certificate
    client_certificate     = module.aks.client_certificate
    client_key             = module.aks.client_key
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "4.0.18"

  create_namespace = true
  namespace        = "ingress-nginx"

  values = [
    file("${path.module}/files/helm/values/ingress-nginx.yaml")
  ]
}

data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = helm_release.ingress_nginx.namespace
  }
}
