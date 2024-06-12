variable "vpc_id" {
    description = "VPC ID"
    type = string
}

variable "private_subnet_ids" {
  description = "Private Subnet ids"
  type = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private Subnet cidrs"
  type = list(string)
}



variable "efs_creation_token" {
    description = "EFS Creation Token"
    type = string
}

variable "cluster_name" {
  description = "cluster name used by discovery for subnet"
  type = string
}

variable "oidc_provider_arn" {
  description = "oidc provider arn"
  type = string
}

