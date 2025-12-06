resource "aws_security_group" "ec2_sg" {
  name        = "assign"
  vpc_id      = var.vpc_id
  description = "Allow ALB EC2 on port 8080"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]   # IMPORTANT
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb_target_group" "tg" {
  name_prefix = "assign"
  port = 8080
  protocol = "HTTP"
  vpc_id = var.vpc_id
  health_check {
    path = "/health"
    protocol = "HTTP"
    interval = 30
    timeout = 5
    unhealthy_threshold = 2
    healthy_threshold = 2
  }
  target_type = "instance"
}

# launch template
resource "aws_launch_template" "lt" {
  name_prefix = "assignment-lt"
  image_id = var.ami_id
  instance_type = var.instance_type
  iam_instance_profile {
    name = var.iam_instance_profile
  }
  network_interfaces {
    associate_public_ip_address = false
    security_groups = [aws_security_group.ec2_sg.id]
  }

  user_data = base64encode(templatefile("${path.module}/user_data.tpl",
    {
      bucket = var.s3_bucket,
      key = var.s3_key,
      region = var.aws_region
    }
  ))
}

resource "aws_autoscaling_group" "asg" {
  name = "assignment-asg"
  desired_capacity = var.asg_desired_capacity
  max_size = max(2, var.asg_desired_capacity)
  min_size = 1
  launch_template {
    id = aws_launch_template.lt.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.private_subnets
  target_group_arns = [aws_lb_target_group.tg.arn]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "assignment-ec2"
    propagate_at_launch = true
  }
}
