#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# Prometheus
kubectl apply -f "./namespaces/observability/prometheus/persistent-volume-claim.prometheus-data.yml"
kubectl apply -f "./namespaces/observability/prometheus/service-account.prometheus.yml"
kubectl apply -f "./namespaces/observability/prometheus/cluster-role.prometheus.yml"
kubectl apply -f "./namespaces/observability/prometheus/cluster-role-binding.prometheus.yml"
kubectl apply -f "./namespaces/observability/prometheus/config-map.prometheus-config.yml"
kubectl apply -f "./namespaces/observability/prometheus/deployment.prometheus.yml"
kubectl apply -f "./namespaces/observability/prometheus/service.prometheus.yml"
kubectl apply -f "./namespaces/observability/prometheus/ingress.prometheus.yml"
kubectl apply -f "./namespaces/observability/prometheus/cron-job.prometheus-data-backup.yml"
