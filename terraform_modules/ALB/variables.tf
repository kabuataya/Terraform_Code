variable "alb_name" {
  description = "the name of the load balancer"
  type = string
}
variable "subnet_ids" {
  description = "The subnet IDs to deploy to"
  type        = list(string)
}
locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}