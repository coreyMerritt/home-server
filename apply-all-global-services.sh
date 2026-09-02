#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

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

# MetalLB
kubectl apply -f "https://raw.githubusercontent.com/metallb/metallb/v0.16.1/config/manifests/metallb-native.yaml"
kubectl wait \
  --all \
  --timeout=300s \
  --for=condition=Ready "pods" \
  --namespace "metallb-system" 
kubectl apply -f "./namespaces/metallb-system/ip-address-pool.yml"
kubectl apply -f "./namespaces/metallb-system/l2-advertisement.yml"

# Ingress-xginx
helm repo add "ingress-nginx" "https://kubernetes.github.io/ingress-nginx"
helm repo update "ingress-nginx"
helm upgrade \
  --install "ingress-nginx" "ingress-nginx/ingress-nginx" \
  --namespace "ingress-nginx" \
  --create-namespace \
  --set "controller.service.type=LoadBalancer"

# Global Resources
dir_path="global"
global_resource_filenames="$(ls ${dir_path}/)"
for resource_filename in $global_resource_filenames; do
  kubectl apply -f "${dir_path}/${resource_filename}"
done
