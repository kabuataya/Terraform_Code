output "alb_dns_name" {
  value = module.web_server_cluster.alb_dns_name
  description = "the IP address of the Load Balancer to Access the web App"
}