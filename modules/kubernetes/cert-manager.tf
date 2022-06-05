variable "cert_manager_acme_email" {
  description = "Email address used for ACME registration"
}

resource "helm_release" "cert_manager" {
  depends_on = [
    helm_release.ingress_nginx
  ]

  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.8.0"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubernetes_manifest" "cluster_issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata"   = {
      "name" = "letsencrypt-prod"
    }
    "spec" = {
      "acme" = {
        "email"               = var.cert_manager_acme_email
        "privateKeySecretRef" = {
          "name" = "letsencrypt-prod"
        }
        "server"  = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "http01" = {
              "ingress" = {
                "class" = "nginx"
              }
            }
          },
        ]
      }
    }
  }
}
