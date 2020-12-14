output "asg_name" {
    value = aws_autoscaling_group.web_server_asg.name
    description = "the name of the auto scaling group"
}
output "alb_dns_name" {
  value = aws_lb.webapp_lb.dns_name
  description = "the IP address of the Load Balancer to Access the web App"
}