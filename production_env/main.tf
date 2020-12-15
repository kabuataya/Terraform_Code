provider "aws" {
  region = "us-east-2"
}
module "web_server_cluster" {
    source = "../web_app"
    cluster_name = "webserver-prod"
    instance_type = "m4.large"
    min_size = 2
    max_size = 10
}
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "scale_out_in_business_hours"
  min_size = 2
  max_size = 10
  desired_capacity = 10
  recurrence = "0 9 * * *"
  autoscaling_group_name = module.web_server_cluster.asg_name
  }
resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale_in_at_night"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"
  autoscaling_group_name = module.web_server_cluster.asg_name
}