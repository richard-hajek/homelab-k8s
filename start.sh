#!/usr/bin/env bash

# Start minikube with host mount for persistent storage
# Data stored in ~/.local/share/k8s-data per XDG Base Directory spec
minikube start --mount --mount-string="$HOME/.local/share/k8s-data:/mnt/k8s-data"

minikube addons enable ingress
minikube addons enable ingress-dns
minikube addons enable dashboard

# Push the new IP to the dnsmasq config
# https://minikube.sigs.k8s.io/docs/handbook/addons/ingress-dns/#installation
echo "server=/lan/$(minikube ip)" | sudo tee /etc/NetworkManager/dnsmasq.d/minikube.conf

tofu apply
