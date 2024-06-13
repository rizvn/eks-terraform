module "users" {
  count = var.deploy["users"] ? 1 : 0
  source = "./extras/users"
  vpc_owner_id = module.vpc.vpc_owner_id
}

module "ebs-csi" {
  depends_on = [module.eks]
  count = var.deploy["ebs_csi"] ? 1 : 0
  source = "./extras/ebs-csi"
  oidc_provider_arn = module.eks.oidc_provider_arn
}


module "aws-loadbalancer-controller" {
  count = var.deploy["aws_lb_ctlr"] ? 1 : 0
  source              = "./extras/aws-loadbalancer-controller"
  oidc_provider_arn   = module.eks.oidc_provider_arn
  cluster_name        = module.eks.cluster_name
  vpc_id              = module.vpc.vpc_id
}

module internal-ingress {
  count = var.deploy["internal_ingress"] ? 1 : 0
  depends_on = [module.aws-loadbalancer-controller]
  source       = "./extras/ingress-nginx"
  ingress-name = "internal-ingress"
  internal     = true
  target-node-labels = "role=ingress-only"
}

module external-ingress {
  count = var.deploy["external_ingress"] ? 1 : 0
  depends_on = [module.aws-loadbalancer-controller]
  source      = "./extras/ingress-nginx"
  ingress-name = "external-ingress"
  internal = false
  target-node-labels = "role=ingress-only"

}

module "karpenter" {
  depends_on = [module.eks]
  count = var.deploy["karpenter"] ? 1 : 0
  source = "./extras/karpenter"
  cluster_name = var.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  cluster_endpoint = module.eks.cluster_endpoint
}


module "cluster-autoscaler" {
  depends_on = [module.eks]
  count = var.deploy["cluster_autoscaler"] ? 1 : 0
  source = "./extras/cluster-autoscaler"
  cluster_name = var.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
}


module "efs" {
  depends_on = [module.eks]
  count = var.deploy["efs"] ? 1 : 0
  source = "./extras/efs"
  cluster_name = var.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  private_subnet_ids = module.vpc.private_subnets
  private_subnet_cidrs = module.vpc.private_subnets_cidr_blocks
  efs_creation_token = "cluster-01-efs"
  vpc_id = module.vpc.vpc_id
}


module "client-vpn" {
  depends_on = [module.vpc]
  count = var.deploy["client_vpn"] ? 1 : 0
  source = "./extras/client-vpn"
  cluster_name = var.cluster_name
  vpc_id = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
  private_subnet_ids = module.vpc.private_subnets

}