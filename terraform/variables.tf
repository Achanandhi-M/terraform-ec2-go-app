variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "asg_desired" {
  type    = number
  default = 1
}

variable "s3_bucket" {
  type = string
}

variable "s3_key" {
  type = string
}

variable "ami_id" {
  type = string
}

