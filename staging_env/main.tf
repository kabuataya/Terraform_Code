provider "aws" {
  region = "us-east-2"
}
module "web_server_cluster" {
    source = "../web_app"
    cluster_name = "webserver-staging"
    instance_type = "t2.micro"
    min_size = 2
    max_size = 2
    custom_tags = {
      owner = "Dev_team"
      DeployedBy = "Terraform"
    }
}
