
output "alb_dns_name" {
  value       = aws_lb.webapp_lb.dns_name
  description = "The domain name of the load balancer"
}

output "alb_http_listener_arn" {
  value       = aws_lb_listener.http_listener.arn
  description = "The ARN of the HTTP listener"
}

output "alb_security_group_id" {
  value       = aws_security_group.lb_web_asg.id
  description = "The ALB Security Group ID"
}