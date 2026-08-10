#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# Ingress-xginx
helm repo add "ingress-nginx" "https://kubernetes.github.io/ingress-nginx"
helm repo update "ingress-nginx"
helm upgrade \
  --install "ingress-nginx" "ingress-nginx/ingress-nginx" \
  --namespace "ingress-nginx" \
  --create-namespace \
  --set "controller.service.type=LoadBalancer"
