output "asg_name" {
    value = aws_autoscaling_group.web_server_asg.name
    description = "the name of the auto scaling group"
}
output "alb_dns_name" {
  value = aws_lb.webapp_lb.dns_name
  description = "the IP address of the Load Balancer to Access the web App"
}
output "alb_security_group_id" {
  value       = aws_security_group.lb_web_asg.id
  description = "The ID of the Security Group attached to the load balancer"
}