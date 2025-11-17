module "changedetection" {
  source     = "./changedetection"
  mount_path = var.mount_path
}

module "n8n" {
  source     = "./n8n"
  mount_path = var.mount_path
}

module "supabase" {
  source     = "./supabase-module"
  mount_path = var.mount_path
}
