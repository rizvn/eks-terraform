
module "ec2_client_vpn" {
  source  = "cloudposse/ec2-client-vpn/aws"
  version = "1.0.0"
  vpc_id                  = var.vpc_id
  client_cidr             = var.vpc_cidr
  organization_name       = var.cluster_name
  logging_enabled         = var.logging_enabled
  retention_in_days       = var.logging_retention_in_days
  logging_stream_name     = var.logging_stream_name
  associated_subnets      = var.private_subnet_ids
  authorization_rules     = var.authorization_rules
  export_client_certificate     = var.export_client_certificate

  ca_common_name          = var.ca_common_name
  server_common_name      = var.server_common_name
  root_common_name        = var.client_common_name
}