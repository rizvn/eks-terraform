
data "aws_region" "current" {}

module "aws-autoscaler-role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                        = "cluster-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [var.cluster_name]



  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}

resource "kubernetes_service_account" "aws-autoscaler-role-sa" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.aws-autoscaler-role.iam_role_arn
    }
  }
}

resource "helm_release" "cluster-autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.37.0"
  namespace  = "kube-system"
  depends_on = [
    kubernetes_service_account.aws-autoscaler-role-sa
  ]

  set{
    name  = "cloudProvider"
    value = "aws"
  }


  set {
    name  = "rbac.serviceAccount.name"
    value = kubernetes_service_account.aws-autoscaler-role-sa.metadata[0].name
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "false"
  }


  set{
    name  = "rbac.create"
    value = true
  }


  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }
}