#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# Grafana
kubectl apply -f "./namespaces/observability/grafana/persistent-volume-claim.grafana-data.yml"
kubectl apply -f "./namespaces/observability/grafana/deployment.grafana.yml"
kubectl apply -f "./namespaces/observability/grafana/service.grafana.yml"
kubectl apply -f "./namespaces/observability/grafana/ingress.grafana.yml"
kubectl apply -f "./namespaces/observability/grafana/cron-job.grafana-data-backup.yml"
