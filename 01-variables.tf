variable "deploy" {
  type = map(bool)

  # set to false to disable the deployment of the following modules
  # don't deploy karpenter and cluster-autoscaler together
  default = {
    internal_ingress   = false
    external_ingress   = true
    aws_lb_ctlr        = true
    users              = true
    karpenter          = false
    cluster-autoscaler = true
    efs                = true
  }
}

variable "region" {
  default = "us-east-1"
}


variable "cluster_name" {
  default = "cluster-01"
}

