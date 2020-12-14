output "asg_name" {
    value = aws_autoscaling_group.aws_autoscaling_group.name
    description = "the name of the auto scaling group"
}
output "alb_dns_name" {
  value = aws_lb.webapp_lb.dns_name
  description = "the IP address of the Load Balancer to Access the web App"
}