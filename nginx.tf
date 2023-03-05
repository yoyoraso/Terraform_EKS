
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  alias = "nginx"
}

resource "kubernetes_namespace" "nginx1" {
  metadata {
    name = "nginx1"
  }
}
resource "kubernetes_deployment" "nginx1" {
  metadata {
    name      = "nginx1"
    namespace = kubernetes_namespace.nginx1.metadata.0.name
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
          image = "nginxdemos/hello"
          name  = "nginx1-container"
          port {
            container_port = 80
          }
        }
        container {
          image = "docker.elastic.co/beats/filebeat:6.2.4"
          name  = "filebeat-container"
        }        
      }
    }
  }
}
resource "kubernetes_service" "nginx1" {
  metadata {
    name      = "nginx1"
    namespace = kubernetes_namespace.nginx1.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.nginx1.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 80
    }
  }
}
