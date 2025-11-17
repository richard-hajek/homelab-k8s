output "namespace" {
  description = "Changedetection namespace name"
  value       = kubernetes_namespace.changedetection.metadata[0].name
}

output "service_endpoint" {
  description = "Changedetection service endpoint"
  value       = "${kubernetes_service.changedetection.metadata[0].name}.${kubernetes_namespace.changedetection.metadata[0].name}.svc.cluster.local:5000"
}
