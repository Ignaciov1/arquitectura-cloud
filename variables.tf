variable "aws_region" {
  description = "Región de AWS donde se creará la infraestructura"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Imagen de Ubuntu 22.04 LTS para la región us-east-1"
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  description = "Tamaño de la instancia EC2"
  default     = "t2.small"
}