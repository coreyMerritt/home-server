#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# To define a node that does have an Nvidia GPU:   kubectl label node <node-name> nvidia.com/gpu.present=true
kubectl apply -f "https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/main/deployments/static/nvidia-device-plugin.yml"
kubectl patch daemonset nvidia-device-plugin-daemonset -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/nodeSelector", "value": {"nvidia.com/gpu.present": "true"}}]'
