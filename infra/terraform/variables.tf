variable "aws_region" {
  description = "Région AWS où déployer l'infra"
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "url-shortener"
}

variable "vpc_cidr" {
  description = "Plage d'adresses IP du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "my_ip" {
  description = "mon IP publique, pour restreindre SSH/Jenkins"
  type        = string
}
