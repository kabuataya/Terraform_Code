variable "server_port" {
  description = "ports the server will connect to"
  type = number
  default = 8080
}
variable "cluster_name" {
  description = "the name to us for the the cluster resources"
  type = string
}