resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description = "VPN endpoint"
  client_cidr_block = "10.1.0.0/24"
  split_tunnel = true
  server_certificate_arn = aws_acm_certificate.server_cert.arn

  security_group_ids = [aws_security_group.vpn_access.id]
  vpc_id = var.vpc_id
  authentication_options {
    type = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.ca_cert.arn
  }
  connection_log_options {
    enabled = false
  }
}

resource "aws_security_group" "vpn_access" {
  vpc_id = var.vpc_id
  name = "vpn-sg"

  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all incoming"
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Client-VPN"
  }
}
resource "aws_ec2_client_vpn_network_association" "vpn_subnets" {
  count = length(var.private_subnet_ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id = element(var.private_subnet_ids, count.index)
  lifecycle {
    // The issue why we are ignoring changes is that on every change
    // terraform screws up most of the vpn assosciations
    // see: https://github.com/hashicorp/terraform-provider-aws/issues/14717
    ignore_changes = [subnet_id]
  }
}

resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr = var.vpc_cidr
  authorize_all_groups = true
}

output "client_vpn_endpoint_url" {
  value = aws_ec2_client_vpn_endpoint.vpn.id
}