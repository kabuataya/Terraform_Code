provider "aws" {
    region = "me-south-1"
}

variable "Web_Port" {
  description = "port used by busy box"
  type = number
  default = 8080
}
resource "aws_instance" "example" {
  ami           = "ami-0df89c0ad05708804"
  instance_type = "t3.nano"
  vpc_security_group_ids = [aws_security_group.Port_8080_Allow.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.Web_Port} &
               EOF
  tags = {
    Name = "terraform-example"
    Type = "Small"
    Create_By = "Kay"
  }
}
resource "aws_security_group" "Port_8080_Allow" {
  name = "terraform-example-instance"

  ingress {
    from_port   = var.Web_Port
    to_port     = var.Web_Port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}