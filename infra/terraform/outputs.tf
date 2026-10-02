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