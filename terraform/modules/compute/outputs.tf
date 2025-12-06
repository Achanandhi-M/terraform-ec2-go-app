output "target_group_arn" {
  value = aws_lb_target_group.tg.arn
}

output "ec2_sg_id" {
  value = aws_security_group.ec2_sg.id
}
