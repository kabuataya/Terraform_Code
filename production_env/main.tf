provider "aws" {
  region = "us-east-2"
}
module "web_server_cluster" {
    source = "../web_app"
    cluster_name = "webserver-prod"
    instance_type = "t2.micro"
    min_size = 2
    max_size = 10
    enable_autoscaling = true
    code_new_version = true
    custom_tags = {
      owner = "production_team"
      DeployedBy = "Terraform"
      vra_depoyment = "yes"
    }
}
/*resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  #count = var.enable_autoscaling ? 1 : 0
  scheduled_action_name = "scale-out-in-business-hours"
  #scheduled_action_name = "${var.cluster_name}-scale-out-in-business-hours"
  min_size = 2
  max_size = 10
  desired_capacity = 10
  recurrence = "0 9 * * *"
  autoscaling_group_name = module.web_server_cluster.asg_name
  #autoscaling_group_name = module.web_server_asg.asg_name
  }
resource "aws_autoscaling_schedule" "scale_in_at_night" {
  #count = var.enable_autoscaling ? 1 : 0
  scheduled_action_name = "scale-in-at-night"
  #scheduled_action_name = "${var.cluster_name}-scale-in-at-night"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"
  autoscaling_group_name = module.web_server_cluster.asg_name
  #autoscaling_group_name = module.web_server_asg.asg_name
}*/