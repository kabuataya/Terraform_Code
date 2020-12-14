variable "server_port" {
  description = "ports the server will connect to"
  type = number
  default = 8080
}
variable "cluster_name" {
  description = "the name to us for the the cluster resources"
  type = string
}

variable "db_remote_Stack_bucket" {
  description = "the name of the s3 bucket"
}

variable "db_remote_State_key" {
  description = "the path for the database remote state in S3"
}