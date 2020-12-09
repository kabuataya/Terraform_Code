provider "aws" {
  region = "us-east-2"
}
resource "aws_instance" "tfexample" {
  ami = "ami-0dd9f0e7df0f0a138"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  tags = {
    "Name" = "tfexample"
  }
}
resource "aws_security_group" "web_server_sg" {
  name = "tfexample_sg"
  ingress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks =["0.0.0.0/0"]
  }
}