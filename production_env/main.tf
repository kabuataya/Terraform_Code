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