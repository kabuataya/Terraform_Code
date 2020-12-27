module "asg" {
  source = "/terraform_modules/ASG"
  cluster_name  = "${var.environment}"
  ami           = var.ami
  user_data     = data.template_file.user_data.rendered
  instance_type = var.instance_type

  min_size           = var.min_size
  max_size           = var.max_size
  enable_autoscaling = true

  subnet_ids        = data.aws_subnet_ids.default.ids
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"
  
  custom_tags = var.custom_tags
}

module "alb" {
  source = "/terraform_modules/ALB"
  alb_name = "${var.environment}"
  subnet_ids = data.aws_subnet_ids.default.ids
}
data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")

  vars = {
    server_port = var.server_port
    server_text = var.server_text
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
  vars = {
    server_port = var.server_port
  }
}
