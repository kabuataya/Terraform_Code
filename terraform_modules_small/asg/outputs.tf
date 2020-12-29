output "asg_name" {
    value = aws_autoscaling_group.web_server_asg.name
    description = "the name of the auto scaling group"
}
output "instace_security_group_id" {
  value       = aws_security_group.web_server_sg.id
  description = "The ID of the Security Group attached to the load balancer"
}