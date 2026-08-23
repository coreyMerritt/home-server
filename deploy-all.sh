#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# Ensure we don't have any poorly named files that will be missed
./lint.sh

# Global & Edge Case
# bash "./apply-all-namespaces.sh"
# bash "./apply-all-secrets.sh"
# bash "./apply-all-global-services.sh"
# kubectl apply -f "./namespaces/observability/node-exporter/daemon-set.node-exporter.yml"
# kubectl apply -f "https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/main/deployments/static/nvidia-device-plugin.yml"
# kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"

ordered_resource_names=(
  "pvc.yml"
  "config-map.yml"
  "service-account.yml"
  "cluster-role.yml"
  "cluster-role-binding.yml"
  "daemon-set.yml"
  "job.yml"
  "cron-job.yml"
  "deployment.yml"
  "ingress.yml"
  "service.yml"
)

for resource_name in "${ordered_resource_names[@]}"; do
  ordered_resource_paths="$(find . -name "$resource_name")"
  for path in $ordered_resource_paths; do
    kubectl apply -f "$path"
  done
done

echo -e "\n\tSuccessfully finished full deployment.\n"