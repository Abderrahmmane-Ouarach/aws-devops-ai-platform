resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-key"
  public_key = file("${pathexpand("~/.ssh/url-shortener-key.pub")}")
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Script d'installation Docker — exécuté une seule fois au premier démarrage
locals {
  install_docker = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl enable docker
    systemctl start docker
    usermod -aG docker ubuntu
  EOF
}

# EC2 App
resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_app_profile.name
  key_name               = aws_key_pair.deployer.key_name
  user_data              = local.install_docker

  tags = {
    Name = "${var.project_name}-ec2-app"
  }
}


# ec2 Jenkins
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  key_name               = aws_key_pair.deployer.key_name
  user_data              = local.install_docker

  tags = {
    Name = "${var.project_name}-ec2-jenkins"
  }
}