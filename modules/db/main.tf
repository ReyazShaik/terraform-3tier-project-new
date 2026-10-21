resource "aws_db_subnet_group" "default" {
  name       = "db-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "this" {
  allocated_storage           = 20
  storage_type                = "gp2"
  engine                      = "mysql"
  engine_version              = "8.0.43"
  instance_class              = var.instance_class
  db_name                     = var.db_name
  username                    = var.db_username
  manage_master_user_password = true # password generated and stored in Secrets Manager
  db_subnet_group_name        = aws_db_subnet_group.default.name
  vpc_security_group_ids      = var.sg_ids
  multi_az                    = var.multi_az
  skip_final_snapshot         = false
  final_snapshot_identifier   = "${var.db_name}-final-snapshot"
  publicly_accessible         = false
  backup_retention_period     = 7
  deletion_protection         = true
}

output "db_endpoint" {
  value = aws_db_instance.this.endpoint
}
