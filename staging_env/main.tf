provider "aws" {
  region = "us-east-2"
}
module "web_server_cluster" {
    source = "../web_app"
    cluster_name = "webserver-staging"
}
