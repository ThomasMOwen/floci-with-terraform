terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.62.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.2.1"
    }
  }
  required_version = "~> 1.15.8"
}

data "aws_eks_cluster" "test-environment" {
  name       = var.cluster_name
  depends_on = [var.cluster_id]
}

data "aws_eks_cluster_auth" "test-environment" {
  name       = var.cluster_name
  depends_on = [var.cluster_id]
}

/*provider "kubernetes" {
  config_path = "~/.kube/config"
} */

provider "kubernetes" {
  host     = "https://floci-eks-${var.cluster_name}:6443"
  insecure = true
  #The line below would be ideally used for a real EKS cluster, but due to local emulation insecure = true is used
  #cluster_ca_certificate = base64decode(data.aws_eks_cluster.test-environment.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.test-environment.token
}

resource "kubernetes_namespace_v1" "environment-namespace" {
  metadata {
    name = "${var.cluster_name}-namespace"
  }
}

resource "kubernetes_deployment_v1" "app" {
  for_each = var.applications
  metadata {
    name      = each.key
    namespace = kubernetes_namespace_v1.environment-namespace.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = each.key
      }
    }

    template {
      metadata {
        labels = {
          app = each.key
        }
      }

      spec {
        container {
          name  = "${each.key}-container"
          image = each.value

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "app" {
  for_each = var.applications
  metadata {
    name      = each.key
    namespace = kubernetes_namespace_v1.environment-namespace.metadata[0].name
  }

  spec {
    selector = {
      app = each.key
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}