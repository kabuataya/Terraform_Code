variable "alb_name" {
  description = "the name of the load balancer"
  type = string
}
variable "subnet_ids" {
  description = "The subnet IDs to deploy to"
  type        = list(string)
}