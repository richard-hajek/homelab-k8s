# Supabase Helm Release
resource "helm_release" "supabase" {
  name             = "supabase"
  repository       = "https://teochenglim.github.io/helm-charts"
  chart            = "supabase"
  namespace        = kubernetes_namespace.supabase.metadata[0].name
  version          = "0.1.2"
  create_namespace = false

  # Values from values.yaml and values.secrets.yaml
  values = [
    file("${path.module}/values.yaml"),
    file("${path.module}/values.secrets.yaml")
  ]

  depends_on = [kubernetes_namespace.supabase]

  # You can override specific values here if needed
  # set {
  #   name  = "db.enabled"
  #   value = "true"
  # }
}
