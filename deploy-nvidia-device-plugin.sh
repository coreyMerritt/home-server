#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# Nvidia
kubectl apply -f "https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/main/deployments/static/nvidia-device-plugin.yml"
