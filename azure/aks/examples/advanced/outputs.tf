output "ingress_ip" {
  description = "IP address of the ingress."
  value       = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip
}
