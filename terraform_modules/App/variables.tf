# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "environment" {
  description = "The name of the environment we're deploying to"
  type        = string
}
# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "server_port" {
  description = "ports the server will connect to"
  type = number
  default = 8080
}

/*variable "cluster_name" {
  description = "the name to use for the the cluster resources"
  type = string
}*/

variable "min_size" {
  description = "the minimum size of the EC2 Instances"
  type = number
  default = 2
}

variable "max_size" {
  description = "the maximum number of the EC2 insatnces"
  type = number
  default = 10
}

variable "instance_type" {
  description = "the type of EC2 instance"
  type = string
  default     = "t2.micro"
}

variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type        = map(string)
  default     = {}
}

variable "enable_autoscaling" {
  description = "if set to true, then autom scale will be anabled"
  type = bool
  default = false
}


variable "ami" {
  description = "the image that will be deployed for the infrastructure"
  default = "ami-0dd9f0e7df0f0a138"
  type = string
}
variable "server_text" {
  description = "the text the web server should return"
  default = "hello, World"
  type = string
}
variable "min_size_upgrade" {
  description = "the minimum number of servers to stay alive during upgrade"
  default = 1
  type = number
}
locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}
