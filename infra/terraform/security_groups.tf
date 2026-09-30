# Security Group pour l'EC2 App
resource "aws_security_group" "app" {
  name        = "${var.project_name}-sg-app"
  description = "SG for the app EC2 instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "App port from Internet"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-app"
  }
}

# Security Group pour l'EC2 Jenkins
resource "aws_security_group" "jenkins" {
  name        = "${var.project_name}-sg-jenkins"
  description = "SG for the Jenkins EC2 instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Jenkins UI from my IP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-jenkins"
  }
}

# Security Group pour RDS
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-sg-rds"
  description = "SG for RDS Postgres"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Postgres from app only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-rds"
  }
}

# Security Group pour ElastiCache Redis
resource "aws_security_group" "redis" {
  name        = "${var.project_name}-sg-redis"
  description = "SG for ElastiCache Redis"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Redis from app only"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-redis"
  }
}