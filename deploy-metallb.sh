#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# MetalLB
kubectl apply -f "https://raw.githubusercontent.com/metallb/metallb/v0.16.1/config/manifests/metallb-native.yaml"
kubectl wait \
  --all \
  --timeout=300s \
  --for=condition=Ready "pods" \
  --namespace "metallb-system" 
kubectl apply -f "./namespaces/metallb-system/metallb/ip-address-pool.homelab-pool.yml"
kubectl apply -f "./namespaces/metallb-system/metallb/l2-advertisement.homelab-l2.yml"
