provider "aws" {
  region = "us-east-2"
}
data "aws_vpc" "default" {
  default = true
}


locals {
  user_data_v1 = templatefile("${path.module}/user-data.sh",{"server_port" = var.server_port})
  user_data_v2 = templatefile("${path.module}/user-data-modefied.sh",{"server_port" = var.server_port})
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}
resource "aws_launch_configuration" "web_server_cluster" {
  image_id = var.ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.web_server_sg.id]
    user_data = var.code_new_version ? local.user_data_v2 : local.user_data_v1
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web_server_asg" {
  launch_configuration = aws_launch_configuration.web_server_cluster.name
  vpc_zone_identifier = data.aws_subnet_ids.default.ids
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"
  min_size = var.min_size
  max_size = var.max_size
  min_elb_capacity = var.min_size_upgrade
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key = "Name"
    value = "${var.cluster_name}-web"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = {
      for key, value in var.custom_tags:
        key => upper(value)
        if key != "Name"
    }
    
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
}
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = var.enable_autoscaling ? 1 : 0
  scheduled_action_name = "${var.cluster_name}-scale-out-in-business-hours"
  min_size = 2
  max_size = 10
  desired_capacity = 10
  recurrence = "0 9 * * *"
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.name
  }
resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name = "${var.cluster_name}-scale-in-at-night"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.name

}
resource "aws_lb" "webapp_lb" {
  name = "${var.cluster_name}-lb"
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.default.ids
  security_groups = [aws_security_group.lb_web_asg.id]
}
resource "aws_alb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority = 100

  condition {
    path_pattern {
    values = ["*"] 
    }
  }

  action {

    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
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


resource "aws_security_group" "web_server_sg" {
  name = "${var.cluster_name}_sg"
}
resource "aws_security_group_rule" "allow_http_inbound_web_server_sg" {
  type = "ingress"
  security_group_id = aws_security_group.web_server_sg.id
  from_port = var.server_port
  to_port = var.server_port
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
}
resource "aws_security_group" "lb_web_asg" {
  name = "${var.cluster_name}-alb"

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

resource "aws_lb_target_group" "asg" {
  name = "${var.cluster_name}-tg"
  port = var.server_port
  protocol = "HTTP"
  vpc_id  = data.aws_vpc.default.id
  
  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}
