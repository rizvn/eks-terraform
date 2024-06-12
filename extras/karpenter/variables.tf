variable "cluster_name" {
  description = "cluster name used by discovery for subnet"
  type = string
}

variable "oidc_provider_arn" {
  description = "oidc provider arn"
  type = string
}

variable "cluster_endpoint" {
  description = "cluster endpoint"
  type = string
}
