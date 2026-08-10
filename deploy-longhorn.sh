#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# Longhorn
helm repo add longhorn https://charts.longhorn.io
helm repo update longhorn
if helm status longhorn -n longhorn-system >/dev/null 2>&1 && \
[[ "$(kubectl get pods -n longhorn-system --no-headers 2>/dev/null | grep -v -c 'Running\|Completed')" -eq 0 ]]; then
  echo "Longhorn already installed and healthy, skipping."
else
  echo "Installing/upgrading Longhorn..."
  helm upgrade \
    --install "longhorn" "longhorn/longhorn" \
    --namespace "longhorn-system" \
    --create-namespace
  echo "Waiting for Longhorn pods to become ready..."
  kubectl wait \
    --all \
    --timeout=300s \
    --for=condition=Ready "pods" \
    --namespace "longhorn-system" 
fi
