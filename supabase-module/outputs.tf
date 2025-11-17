output "namespace" {
  description = "Supabase namespace name"
  value       = kubernetes_namespace.supabase.metadata[0].name
}

output "release_status" {
  description = "Supabase Helm release status"
  value       = helm_release.supabase.status
}
