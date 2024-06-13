
module "ebs-csi-driver-irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39.1"
  role_name      = "ebs-csi-driver-irsa"
  attach_ebs_csi_policy = true
  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa", "kube-system:ebs-csi-node-sa"]
    }
  }
}

resource "kubernetes_service_account" "ebs-csi-controller-sa" {
  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn"   = module.ebs-csi-driver-irsa.iam_role_arn
    }
  }
}


resource "kubernetes_service_account" "ebs-csi-node-sa" {
  metadata {
    name      = "ebs-csi-node-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn"    = module.ebs-csi-driver-irsa.iam_role_arn
    }
  }
}


resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  allow_volume_expansion = true
  parameters = {
    encrypted = "true"
    fsType     = "ext4"
    type = "gp3"
  }
}


