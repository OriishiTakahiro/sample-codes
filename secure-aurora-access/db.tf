# ---------------------
# Aurora Cluster
# ---------------------

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier = "sample-aurora-cluster"
  engine             = "aurora-postgresql"
  database_name      = "sample"

  # マスタユーザーのパスワードは、AWS Secrets Managerで管理
  master_username             = "sample_user"
  manage_master_user_password = true

  vpc_security_group_ids = [aws_security_group.aurora_cluster.id]
  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  storage_encrypted      = true

  # サンプルコードなのでterraform destroyで綺麗に削除したい
  deletion_protection     = false
  skip_final_snapshot     = true
  backup_retention_period = 1

  tags = {
    Name = "sample-aurora-cluster"
  }
}

resource "aws_rds_cluster_instance" "aurora_cluster_instance" {
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  # ts.medium はPostgres互換の最小サイズ
  # FYI. https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html
  instance_class = "db.t3.medium"
  engine         = aws_rds_cluster.aurora_cluster.engine
  engine_version = aws_rds_cluster.aurora_cluster.engine_version

  tags = {
    Name = "sample-aurora-cluster-instance"
  }
}

# ---------------------
# Aurora Cluster
# ---------------------

resource "aws_security_group" "aurora_cluster" {
  name   = "sample-aurora-cluster-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sample-aurora-cluster-sg"
  }
}
