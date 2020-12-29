# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "server_port" {
  description = "ports the server will connect to"
  type = number
  default = 8080
}

variable "cluster_name" {
  description = "the name to use for the the cluster resources"
  type = string
}

variable "min_size" {
  description = "the minimum size of the EC2 Instances"
  type = number
}

variable "max_size" {
  description = "the maximum number of the EC2 insatnces"
  type = number
}

variable "instance_type" {
  description = "the type of EC2 instance"
}

variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type        = map(string)
  default     = {}
}

variable "enable_autoscaling" {
  description = "if set to true, then autom scale will be anabled"
  type = bool
  default = true
}
variable "ami" {
  description = "the image that will be deployed for the infrastructure"
  default = "ami-0dd9f0e7df0f0a138"
  type = string
}
variable "subnet_ids" {
  description = "The subnet IDs to deploy to"
  type        = list(string)
}
variable "target_group_arns" {
  description = "The ARNs of ELB target groups in which to register Instances"
  type        = list(string)
  default     = []
}
variable "health_check_type" {
  description = "The type of health check to perform. Must be one of: EC2, ELB."
  type        = string
  default     = "EC2"
}
variable "user_data" {
  description = "The User Data script to run in each Instance at boot"
  type        = string
  default     = null
}