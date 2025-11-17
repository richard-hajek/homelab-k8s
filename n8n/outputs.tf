output "namespace" {
  description = "n8n namespace name"
  value       = kubernetes_namespace.n8n.metadata[0].name
}

output "service_endpoint" {
  description = "n8n service endpoint"
  value       = "${kubernetes_service.n8n.metadata[0].name}.${kubernetes_namespace.n8n.metadata[0].name}.svc.cluster.local:5678"
}
