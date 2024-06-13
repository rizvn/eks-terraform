resource "null_resource" "self_signed_ca" {
  provisioner "local-exec" {
    command = <<EOF
    mkdir certs
    openssl genrsa -out certs/ca.key 1024
    openssl req -x509 -new -nodes -key certs/ca.key -sha256 -days 1024 -out certs/ca.crt -subj "/CN=ca.vpn-${var.cluster_name}"
    EOF
  }
  triggers = {
    # This trigger checks if the file exists
    file_check = "certs/ca.crt"
  }
  # Prevent recreation of the file unless it does not exist
  lifecycle {
    create_before_destroy = false
  }
}

resource "null_resource" "self_signed_server_cert" {
  depends_on = [null_resource.self_signed_ca]
  provisioner "local-exec" {
    command = <<EOF
    openssl genrsa -out certs/server.key 1024
    openssl req -new -key certs/server.key -out certs/server.csr -subj "/CN=server.vpn-${var.cluster_name}"
    openssl x509 -req -in certs/server.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/server.crt -days 500 -sha256 -extensions v3_req -extfile extras/client-vpn/key-usage-server.conf
    EOF
  }
  triggers = {
    # This trigger checks if the file exists
    file_check = "certs/server.crt"
  }
  # Prevent recreation of the file unless it does not exist
  lifecycle {
    create_before_destroy = false
  }
}


resource "null_resource" "self_signed_client_cert" {
  depends_on = [null_resource.self_signed_ca]
  provisioner "local-exec" {
    command = <<EOF
    openssl genrsa -out certs/client.key 1024
    openssl req -new -key certs/client.key -out certs/client.csr -subj "/CN=client.vpn-${var.cluster_name}"
    openssl x509 -req -in certs/client.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/client.crt -days 500 -sha256  -extensions v3_req -extfile extras/client-vpn/key-usage-client.conf
    EOF
  }
  triggers = {
    # This trigger checks if the file exists
    file_check = "certs/client.crt"
  }
  # Prevent recreation of the file unless it does not exist
  lifecycle {
    create_before_destroy = false
  }
}

data "local_file" "ca_cert" {
  depends_on = [null_resource.self_signed_ca]
  filename = "certs/ca.crt"
}

data "local_file" "ca_key" {
  depends_on = [null_resource.self_signed_ca]
  filename = "certs/ca.key"
}


data "local_file" "server_cert" {
  depends_on = [null_resource.self_signed_server_cert]
  filename = "certs/server.crt"
}

data "local_file" "server_key" {
  depends_on = [null_resource.self_signed_server_cert]
  filename = "certs/server.key"
}

data "local_file" "client_cert" {
  depends_on = [null_resource.self_signed_client_cert]
  filename = "certs/client.crt"
}

data "local_file" "client_key" {
  depends_on = [null_resource.self_signed_client_cert]
  filename = "certs/client.key"
}

resource "aws_acm_certificate" "ca_cert" {
  depends_on = [null_resource.self_signed_ca]
  private_key      = data.local_file.ca_key.content
  certificate_body = data.local_file.ca_cert.content
  tags = {
    Name = "self-signed-ca-cert"
  }
}

resource "aws_acm_certificate" "server_cert" {
  depends_on = [null_resource.self_signed_server_cert]
  private_key      = data.local_file.server_key.content
  certificate_body = data.local_file.server_cert.content
  certificate_chain = data.local_file.ca_cert.content
  tags = {
    Name = "self-signed-server-cert"
  }
}

resource "aws_acm_certificate" "client_cert" {
  depends_on = [null_resource.self_signed_client_cert]
  private_key      = data.local_file.client_key.content
  certificate_body = data.local_file.client_cert.content
  certificate_chain = data.local_file.ca_cert.content
  tags = {
    Name = "self-signed-client-cert"
  }
}