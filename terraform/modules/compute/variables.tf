variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "instance_type" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "iam_instance_profile" {
  type = string
}

variable "s3_bucket" {
  type = string
}

variable "s3_key" {
  type = string
}

variable "asg_desired_capacity" {
  type = number
}

variable "aws_region" {
  type = string
}

variable "alb_sg_id" {
  type = string
}
