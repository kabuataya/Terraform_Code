resource "aws_launch_configuration" "web_server_cluster" {
  image_id = var.ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.web_server_sg.id]
  user_data = (length(data.template_file.user_data[*]) > 0 
    ? data.template_file.user_data[0].rendered
    : data.template_file.user_data_v2[0].rendered
    )
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