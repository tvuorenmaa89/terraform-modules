/**
  * # Azure AD POD Identity (AAD-POD-Identity)
  *
  * This module is used to add [`aad-pod-identity`](https://github.com/Azure/aad-pod-identity) to Kubernetes clusters (tested with AKS).
  */

terraform {
  required_version = "0.13.5"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "1.13.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "1.3.2"
    }
  }
}

locals {
  name      = "aad-pod-identity"
  namespace = "aad-pod-identity"
  version   = "2.1.0"
}

locals {
  values = templatefile("${path.module}/templates/values.yaml.tpl", { namespaces = var.namespaces, aad_pod_identity = var.aad_pod_identity })
}

resource "kubernetes_namespace" "this" {
  metadata {
    labels = {
      name = local.namespace
    }
    name = local.namespace
  }
}

resource "helm_release" "aad_pod_identity" {
  repository = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
  chart      = local.name
  name       = local.name
  version    = local.version
  namespace  = kubernetes_namespace.this.metadata[0].name
  values     = [local.values]
}
