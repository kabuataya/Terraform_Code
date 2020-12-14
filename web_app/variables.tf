variable "server_port" {
  description = "ports the server will connect to"
  type = number
  default = 8080
}
variable "cluster_name" {
  description = "the name to us for the the cluster resources"
  type = string
}
variable "min_size" {
  description = "the minumum size of the EC2 Instances"
  type = number
}

variable "max_size" {
  description = "the maximum number of the EC2 insatnces"
  type = number
}
variable "instance_type" {
  description = "the type of EC2 instance"
  
}