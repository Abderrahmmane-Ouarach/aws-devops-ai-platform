output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}


output "ec2_app_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_app_profile.name
}

output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.main.cache_nodes[0].address
}


output "ec2_app_public_ip" {
  value = aws_instance.app.public_ip
}

output "ec2_jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

