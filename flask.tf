provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  alias = "flask"
}


resource "kubernetes_namespace" "flask" {
  metadata {
    name = "flask"
  }
}
resource "kubernetes_deployment" "flask" {
  metadata {
    name      = "flask"
    namespace = kubernetes_namespace.flask.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "MyTestApp"
      }
    }
    template {
      metadata {
        labels = {
          app = "MyTestApp"
        }
      }
      spec {
        container {
          image = "yoyoraso/iti-flask-lab2:latest"
          name  = "flask-container"
          port {
            container_port = 5000
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "flask" {
  metadata {
    name      = "flask"
    namespace = kubernetes_namespace.flask.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.flask.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 5000
      target_port = 5000
    }
  }
}
