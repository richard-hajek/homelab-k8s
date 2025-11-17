variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kubernetes context to use (defaults to minikube)"
  type        = string
  default     = "minikube"
}

variable "mount_path" {
  description = "Minikube container storage path"
  type        = string
  default     = "/mnt/k8s-data"
}
