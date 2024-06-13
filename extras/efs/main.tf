
resource "aws_efs_file_system" "efs" {
  creation_token = var.efs_creation_token
  encrypted = true

  tags = {
    cluster = var.cluster_name
  }
}

resource "aws_efs_access_point" "efs_ap" {
  file_system_id = aws_efs_file_system.efs.id
  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/"

    creation_info {
      owner_gid = 1000
      owner_uid = 1000
      permissions = "770"
    }
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
  reclaim_policy = "Delete"

  parameters = {
    directoryPerms = "770"
    fileSystemId = aws_efs_file_system.efs.id
    gidRangeStart = "1000"
    gidRangeEnd = "3000"
    provisioningMode = "efs-ap"
    uidRangeStart=  "1000"
    uidRangeEnd = "3000"

  }
}


