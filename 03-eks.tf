module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.13.1"

  cluster_name    = "cluster-01"
  cluster_version = "1.30"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true


  create_kms_key = true
  cluster_encryption_config = {
    resources = ["secrets"]
  }

  # create can be admin
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  node_security_group_enable_recommended_rules = true

  enable_irsa = true

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
  }


  cluster_addons = {
    vpc-cni = {
      most_recent              = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      before_compute           = true
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
      })
    },
    kube-proxy = {
      most_recent = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = module.deny_all_irsa.iam_role_arn
    },
    coredns = {
      most_recent = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = module.deny_all_irsa.iam_role_arn
    }

  }

  eks_managed_node_group_defaults = {
    disk_size = 50
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    general = {
      desired_size = 1
      min_size     = 1
      max_size     = 10
      labels = {
        role = "general"
      }

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }


    ingress_only = {
      desired_size = 3
      min_size     = 3
      max_size     = 10
      labels = {
        role = "ingress-only"
      }
      taints = [
        {
          key = "role"
          value = "ingress-only"
          effect = "NO_SCHEDULE"
        }
      ]
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND" # or SPOT
    }
    #spot = {
    #  desired_size = 1
    #  min_size     = 1
    #  max_size     = 10
    #  labels = {
    #    role = "spot"
    #  }
    #  taints = [{
    #    key    = "market"
    #    value  = "spot"
    #    effect = "NO_SCHEDULE"
    #  }]
    #  instance_types = ["t3.micro"]
    #  capacity_type  = "SPOT"
    # }
  }

  authentication_mode = "API_AND_CONFIG_MAP"


  tags = {
    Environment = "dev"
  }
}


output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}



module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39.1"

  role_name_prefix      = "vpc-cni-irsa-"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}


module "deny_all_irsa" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name_prefix = "EKS-IRSA-DenyAll"

  role_policy_arns = {
    policy = "arn:aws:iam::aws:policy/AWSDenyAll"
  }

  oidc_providers = {
    cluster-oidc-provider = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = []
    }
  }
}
