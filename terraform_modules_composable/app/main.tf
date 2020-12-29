provider "aws" {
  region = "us-east-2"
}
module "asg" {
  source = "../asg"
  cluster_name  = var.environment
  ami           = var.ami
  user_data     = data.template_file.user_data.rendered
  instance_type = var.instance_type

  min_size           = var.min_size
  max_size           = var.max_size
  enable_autoscaling = var.enable_autoscaling

  subnet_ids        = data.aws_subnet_ids.default.ids
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"
  custom_tags = var.custom_tags
}

module "alb" {
  #source = "/terraform_modules/alb"
  source = "../alb"

  alb_name = "ELB-${var.environment}"
  subnet_ids = data.aws_subnet_ids.default.ids
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
  #template = file("../app/user-data.sh")
  vars = {
    server_port = var.server_port
  }
}

resource "aws_lb_target_group" "asg" {
  name = "${var.environment}-tg"
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

resource "aws_alb_listener_rule" "asg" {
  listener_arn = module.alb.alb_http_listener_arn
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
data "aws_vpc" "default" {
  default = true
}
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}
