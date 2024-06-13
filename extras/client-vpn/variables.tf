
variable "cluster_name" {
    type = string
  description = "Name of eks cluster"
}

variable "vpc_cidr" {
  type = string
  description = "VPC cidr block"
}

variable "logging_enabled" {
  type = bool
  description = "Enable logging"
}

variable "logging_retention_in_days" {
  type        = number
  description = "Retention in days"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet ids"
}

variable "authorization_rules" {
  description = "Authorization rules"
  default = []
}


variable "log_group" {
  type = string
  default = "cvpn-log-group"
}


variable "logging_stream_name" {
  type = string
  default = "cvpn-log-stream"
}


variable "export_client_certificate" {
  type = string
  default = "cvpn-log-stream"
}


variable "ca_common_name" {
  type = string
  description = "Common name for the CA"
}

variable "server_common_name" {
  type = string
  description = "Common name for the server"
}


variable "client_common_name" {
  type = string
  description = "Common name for the client"
}


variable "vpc_id" {
  type = string
  description = "VPC id"
}