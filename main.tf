provider "aws" {
    region = "me-south-1"
}

variable "Web_Port" {
  description = "port used by busy box"
  type = number
  default = 8080
}
variable "Server_Count" {
  description = "number of servers to be deployed"
  type = number
  default = 2
}

data "aws_vpc" "default" {
  default = true
}
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}
resource "aws_launch_configuration" "Web_Servers" {
  image_id        = "ami-0df89c0ad05708804"
  instance_type   = "t3.nano"
  security_groups = [aws_security_group.Port_8080_Allow.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World. this is terraform learning by Karam" > index.html
              nohup busybox httpd -f -p ${var.Web_Port} &
              EOF
  lifecycle {
    create_before_destroy = true
            }
}
resource "aws_autoscaling_group" "Web_Scale" {
  launch_configuration = aws_launch_configuration.Web_Servers.name
  vpc_zone_identifier = data.aws_subnet_ids.default.ids
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10
  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}
resource "aws_lb" "port_8080_lb" {
  name               = "terraform-asg-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_listener" "http_8080_listener" {
  load_balancer_arn = aws_lb.port_8080_lb.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}


resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http_8080_listener.arn
  priority     = 100

  condition {
    field  = "path-pattern"
    values = ["*"]
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}
resource "aws_security_group" "alb_sg" {
  name = "terraform-example-alb"

  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = var.Web_Port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

#resource "aws_instance" "example" {
#  ami           = "ami-0df89c0ad05708804"
#  instance_type = "t3.nano"
#  vpc_security_group_ids = [aws_security_group.Port_8080_Allow.id]
#  user_data = <<-EOF
#              #!/bin/bash
#              echo "Hello, World. this is terraform learning by Karam" > index.html
#              nohup busybox httpd -f -p ${var.Web_Port} &
#               EOF
#  tags = {
#    Name = "terraform-example"
#    Type = "Small"
#    Create_By = "Kay"
#  }
#}
resource "aws_security_group" "Port_8080_Allow" {
  name = "terraform-example-instance"

  ingress {
    from_port   = var.Web_Port
    to_port     = var.Web_Port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "alb_dns_name" {
  value       = aws_lb.port_8080_lb.dns_name
  description = "The domain name of the load balancer"
}