provider "aws" {
    region = "me-south-1"
}
resource "aws_instance" "example" {
  ami           = "ami-0df89c0ad05708804"
  instance_type = "t3.nano"

  tags = {
    Name = "terraform-example"
    Type = "Small"
    Create_By = "Kay"
  }
}