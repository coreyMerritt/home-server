#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

bash apply-all-namespaces.sh
bash apply-all-secrets.sh
bash apply-all-global-services.sh
bash deploy-metrics-server.sh
bash deploy-longhorn.sh
bash deploy-metallb.sh
bash deploy-ingress-nginx.sh
bash deploy-node-exporter.sh
bash deploy-jellyfin.sh
bash deploy-job-listing-data-manager.sh
bash deploy-job-listing-gui.sh
bash deploy-prometheus.sh
bash deploy-grafana.sh
bash deploy-sc2-data-manager.sh
bash deploy-printer.sh
