variable "deploy" {
  type = map(bool)

  # set to false to disable the deployment of the following modules
  # don't deploy karpenter and cluster-autoscaler together
  default = {
    internal_ingress   = false
    external_ingress   = false
    aws_lb_ctlr        = false
    users              = false
    karpenter          = false
    cluster-autoscaler = false
    efs                = false
    client-vpn         = false
  }
}

variable "region" {
  default = "us-east-1"
}


variable "cluster_name" {
  default = "cluster-01"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

