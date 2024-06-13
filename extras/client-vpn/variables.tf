
variable "cluster_name" {
    type = string
  description = "Name of eks cluster"
}

variable "vpc_cidr" {
  type = string
  description = "VPC cidr block"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet ids"
}


variable "vpc_id" {
  type = string
  description = "VPC id"
}