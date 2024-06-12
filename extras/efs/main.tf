
resource "aws_efs_file_system" "efs" {
  creation_token = var.efs_creation_token
  encrypted = true

  tags = {
    cluster = var.cluster_name
  }
}


resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.efs.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_security_group" "efs-sg" {
  name        = "eks_allow_nfs"
  description = "Allow NFS traffic from EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }
}


resource "aws_efs_mount_target" "mounts" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs-sg.id]
}

resource "kubernetes_storage_class" "nfs" {
  depends_on = [helm_release.aws_efs_csi_driver]
  metadata {
    name = "nfs"
  }
  storage_provisioner = "efs.csi.aws.com"

  parameters = {
    provisioner = "efs.csi.aws.com"
    file_system_id = aws_efs_file_system.efs.id
  }
}