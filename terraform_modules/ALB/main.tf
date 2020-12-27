resource "aws_lb" "webapp_lb" {
  name = var.alb_name
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.default.ids
  security_groups = [aws_security_group.lb_web_asg.id]
}
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.webapp_lb.arn
  port = local.http_port
  protocol = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}
resource "aws_security_group" "lb_web_asg" {
  name = var.alb_name
  /*ingress {
    from_port = local.http_port
    to_port = local.http_port
    protocol = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
  egress {
    from_port = local.any_port
    to_port = local.any_port
    protocol = local.any_protocol
    cidr_blocks = local.all_ips
  }*/
}
resource "aws_security_group_rule" "allow_http_inbound_lb_web_asg" {
  type = "ingress"
  security_group_id = aws_security_group.lb_web_asg.id
    from_port = local.http_port
    to_port = local.http_port
    protocol = local.tcp_protocol
    cidr_blocks = local.all_ips
}
resource "aws_security_group_rule" "allow_http_outbound_lb_web_asg" {
  type = "egress"
  security_group_id = aws_security_group.lb_web_asg.id
  from_port = local.any_port
  to_port = local.any_port
  protocol = local.any_protocol
  cidr_blocks = local.all_ips
}
