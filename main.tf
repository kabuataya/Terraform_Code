provider "aws" {
    region = "me-south-1"
}
resource "aws_instance" "example" {
  ami           = "ami-045372f5171e9380c"
  instance_type = "t3.micro"
}