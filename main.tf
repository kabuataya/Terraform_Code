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
  min_size = 2
  max_size = 10
  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
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