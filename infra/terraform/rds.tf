# Groupe de subnets — dit à RDS dans quel(s) subnet(s) il a le droit de vivre
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.private.id]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier        = "${var.project_name}-db"
  engine            = "postgres"
  engine_version    = "16.3"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "urlshortener"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  skip_final_snapshot = true
  publicly_accessible = false

  tags = {
    Name = "${var.project_name}-rds"
  }
}