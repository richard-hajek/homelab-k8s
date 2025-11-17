resource "kubernetes_namespace" "supabase" {
  metadata {
    name = "supabase"
  }
}
