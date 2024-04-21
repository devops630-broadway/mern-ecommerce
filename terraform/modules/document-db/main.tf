
resource "random_password" "password" {
  count   = var.master_password == "" ? 1 : 0
  length  = 16
  special = false
}

resource "aws_docdb_cluster" "default" {
  cluster_identifier              = var.db_cluster_name
  master_username                 = var.master_username
  master_password                 = var.master_password != "" ? var.master_password : random_password.password[0].result
  backup_retention_period         = var.retention_period
  preferred_backup_window         = var.preferred_backup_window
  apply_immediately               = var.apply_immediately
  port                            = var.db_port
  engine                          = var.engine
  engine_version                  = var.engine_version
}

resource "aws_docdb_cluster_instance" "default" {
  count                        = var.cluster_size
  identifier                   = "${var.db_cluster_name}-instance-${count.index + 1}"
  cluster_identifier           = join("", aws_docdb_cluster.default[*].id)
  instance_class               = var.instance_class
  engine                       = var.engine
  apply_immediately            = var.apply_immediately

}


