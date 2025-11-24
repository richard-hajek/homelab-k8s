# Kubernetes Infrastructure Configuration

OpenTofu/Terraform-managed Kubernetes infrastructure running on Minikube for local development and self-hosted services.

## Architecture

This repository manages the following applications:

- **changedetection.io** - Website change monitoring with Playwright browser automation
- **n8n** - Workflow automation platform
- **Supabase** - Open-source Firebase alternative (PostgreSQL, Auth, Storage, Realtime)

### Technology Stack

- **IaC**: OpenTofu (Terraform-compatible)
- **Kubernetes**: Minikube with local persistent storage
- **Ingress**: NGINX Ingress Controller with local DNS resolution
- **Storage**: Local StorageClass with host path mounts

## Prerequisites

- Minikube
- OpenTofu or Terraform
- kubectl
- helm (for Supabase deployment)
- NetworkManager with dnsmasq (for `.lan` DNS resolution)

## Storage Architecture

Persistent data is stored on the host filesystem following XDG Base Directory specification:

```
~/.local/share/k8s-data/
├── changedetection/
├── n8n/
└── supabase/
```

Minikube mounts this directory to `/mnt/k8s-data` inside the cluster, accessible via the `local-storage` StorageClass.

## Quick Start

### Initial Setup

```bash
# Start Minikube with persistent storage mount and required addons
./start.sh
```

This script:
1. Starts Minikube with host mount (`~/.local/share/k8s-data:/mnt/k8s-data`)
2. Enables ingress, ingress-dns, and dashboard addons
3. Configures dnsmasq for `.lan` domain resolution
4. Applies the OpenTofu configuration

### Manual Deployment

```bash
# Start Minikube with host mount
minikube start --mount --mount-string="$HOME/.local/share/k8s-data:/mnt/k8s-data"

# Enable required addons
minikube addons enable ingress
minikube addons enable ingress-dns
minikube addons enable dashboard

# Configure local DNS resolution for .lan domains
echo "server=/lan/$(minikube ip)" | sudo tee /etc/NetworkManager/dnsmasq.d/minikube.conf
sudo systemctl restart NetworkManager

# Initialize and apply infrastructure
tofu init
tofu plan
tofu apply
```

## Service Access

After deployment, services are accessible via:

- **Changedetection**: http://changedetector.lan
- **n8n**: http://n8n.lan
- **Supabase Studio**: (configured in `supabase-module/values.yaml`)

## Module Structure

### changedetection/

Deploys changedetection.io with sidecar browser automation:

- **Main container**: `dgtlmoon/changedetection.io` (256Mi-512Mi RAM, 100m-500m CPU)
- **Browser sidecar**: `dgtlmoon/sockpuppetbrowser` (512Mi-1Gi RAM, 200m-1000m CPU)
- **Storage**: 5Gi PVC mounted at `/datastore`
- **Timezone**: Europe/Prague

Key configuration:
- Playwright driver on localhost:3000
- Browser runs with SYS_ADMIN capability for Chrome sandboxing
- Max 10 concurrent Chrome processes

### n8n/

Workflow automation platform deployment:

- **Container**: `docker.n8n.io/n8nio/n8n` (256Mi-512Mi RAM, 100m-500m CPU)
- **Storage**: 5Gi PVC mounted at `/home/node/.n8n`
- **Timezone**: Europe/Prague
- **Security**: Secure cookies disabled for local development

### supabase-module/

Helm-based Supabase deployment with custom configuration:

- Chart source: Embedded Helm chart in `chart/charts/supabase/`
- Configuration: `values.yaml` and `secrets.yaml`
- Components: PostgreSQL, Auth, Storage, Realtime, REST API, Studio

## Configuration

### Variables

Configured in `variables.tf`:

| Variable | Description | Default |
|----------|-------------|---------|
| `kubeconfig_path` | Path to kubeconfig | `~/.kube/config` |
| `kube_context` | Kubernetes context | `minikube` |
| `mount_path` | Storage mount path in cluster | `/mnt/k8s-data` |

### Customization

Override variables via:

```bash
# CLI flags
tofu apply -var="kube_context=my-context"

# Environment variables
export TF_VAR_mount_path="/custom/path"
tofu apply

# terraform.tfvars file
cat > terraform.tfvars <<EOF
kube_context = "my-context"
mount_path = "/custom/path"
EOF
```

## Storage Management

### Creating StorageClass

The repository expects a `local-storage` StorageClass. Create it manually:

```bash
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF
```

### Backing Up Data

```bash
# Backup all persistent data
tar -czf k8s-backup-$(date +%Y%m%d).tar.gz ~/.local/share/k8s-data/

# Backup specific service
tar -czf changedetection-backup.tar.gz ~/.local/share/k8s-data/changedetection/
```

## Troubleshooting

### DNS Resolution Not Working

```bash
# Verify dnsmasq configuration
cat /etc/NetworkManager/dnsmasq.d/minikube.conf

# Check Minikube IP
minikube ip

# Restart NetworkManager
sudo systemctl restart NetworkManager

# Test resolution
dig changedetector.lan
```

### Persistent Storage Issues

```bash
# Verify mount inside Minikube
minikube ssh
ls -la /mnt/k8s-data

# Check PV/PVC status
kubectl get pv,pvc -A

# Verify StorageClass
kubectl get storageclass
```

### Pod Not Starting

```bash
# Check pod status and events
kubectl get pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace>

# View logs
kubectl logs <pod-name> -n <namespace>

# For multi-container pods (changedetection)
kubectl logs <pod-name> -n changedetection -c changedetection
kubectl logs <pod-name> -n changedetection -c browser-sockpuppet
```

### Resource Constraints

Monitor cluster resources:

```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods -A

# Check resource requests/limits
kubectl describe nodes
```

## Development Workflow

### Adding New Services

1. Create module directory: `mkdir -p new-service`
2. Define resources: `new-service/deployment.tf`, `new-service/namespace.tf`, etc.
3. Add to root module: Edit `main.tf`
4. Create storage definition in `new-service/storage.tf`
5. Apply: `tofu apply`

### Updating Existing Services

```bash
# Format code
tofu fmt -recursive

# Validate configuration
tofu validate

# Preview changes
tofu plan

# Apply changes
tofu apply
```

### Managing Helm Charts (Supabase)

```bash
# Update Supabase values
vim supabase-module/values.yaml

# Preview Helm changes
tofu plan -target=module.supabase

# Apply Helm changes
tofu apply -target=module.supabase

# Direct Helm operations
helm list -n supabase
helm get values supabase -n supabase
```

## Security Considerations

- This configuration is designed for **local development only**
- No TLS/SSL encryption on ingress endpoints
- Secrets should be moved to proper secret management for production use
- `SYS_ADMIN` capability required for changedetection browser container
- Consider using cert-manager for TLS in non-local environments

## Maintenance

### Updating Images

Image versions are hardcoded in deployment manifests. To update:

```bash
# Edit deployment files
vim changedetection/changedetection.tf  # Update image tags
vim n8n/n8n.tf                          # Update image tags

# Apply changes
tofu apply
```

### Cleaning Up

```bash
# Destroy all infrastructure
tofu destroy

# Clean up data (WARNING: Destructive)
rm -rf ~/.local/share/k8s-data/*

# Stop Minikube
minikube stop

# Delete Minikube cluster
minikube delete
```

## References

- [OpenTofu Documentation](https://opentofu.org/docs/)
- [Minikube Handbook](https://minikube.sigs.k8s.io/docs/)
- [Changedetection.io](https://github.com/dgtlmoon/changedetection.io)
- [n8n Documentation](https://docs.n8n.io/)
- [Supabase Self-Hosting](https://supabase.com/docs/guides/self-hosting)
