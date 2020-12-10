provider "aws" {
  region = "us-east-2"
}
variable "server_port" {
  description = "ports the server will connect to"
  type = number
  default = 8080
}
data "aws_vpc" "default" {
  default = true
}
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}
resource "aws_launch_configuration" "web_server_cluster" {
  image_id = "ami-0dd9f0e7df0f0a138"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.web_server_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web_server_asg" {
  launch_configuration = aws_launch_configuration.web_server_cluster.name
  vpc_zone_identifier = data.aws_subnet_ids.default.ids
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"
  min_size = 2
  max_size = 10
  tag {
    key = "Name"
    value = "tf_Asg_web"
    propagate_at_launch = true
  }
}
resource "aws_lb" "webapp_lb" {
  name = "webserverlb"
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
  port = 80
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

/*
resource "aws_instance" "tfexample" {
  ami = "ami-0dd9f0e7df0f0a138"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  tags = {
    "Name" = "tfexample"
  }
}
*/
resource "aws_security_group" "web_server_sg" {
  name = "tfexample_sg"
  ingress {
      from_port = var.server_port
      to_port = var.server_port
      protocol = "tcp"
      cidr_blocks =["0.0.0.0/0"]
  }
}
resource "aws_security_group" "lb_web_asg" {
  name = "web_sg_alb"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "asg" {
  name = "web-server-tg"
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
    #output "public_ip_address" {
    #value = aws_instance.tfexample.public_ip
    #description = "the public ip address of the deployed machine"
#}

output "alb_dns_name" {
  value = aws_lb.webapp_lb.dns_name
  description = "the IP address of the Load Balancer to Access the web App"
}