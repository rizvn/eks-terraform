//based on https://dev.to/segoja7/scaling-an-aws-eks-with-karpenter-using-helm-provider-with-terraform-kubernetes-series-episode-4-1dp6
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.13.1"

  cluster_name                    = var.cluster_name
  irsa_oidc_provider_arn          = var.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  enable_irsa = true

  create_iam_role      = true
  iam_role_name        = "KarpenterController"

  create_node_iam_role = true
  node_iam_role_name   = "KarpenterNode"


  tags = {
    Environment = "dev"
  }
}


resource "helm_release" "karpenter" {
  depends_on = [module.karpenter]
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  #repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  #repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart      = "karpenter"
  version    = "v0.31.3" #"v0.36.2"

  set {
    name  = "settings.aws.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.aws.clusterEndpoint"
    value = var.cluster_endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.iam_role_arn
    #value =  module.karpenter.iam_role_arn
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = module.karpenter.node_iam_role_name
  }

  set {
    name  = "settings.aws.interruptionQueueName"
    value = module.karpenter.queue_name
  }
}


output "karpenter_controller_role_name" {
  value = module.karpenter.iam_role_name
}

output "karpenter_node_role_name" {
  value = module.karpenter.node_iam_role_name
}
