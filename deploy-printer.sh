#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# Printer
kubectl apply -f "./namespaces/printer/printer-maintenance/config-map.printer-maintenance.yml"
kubectl apply -f "./namespaces/printer/printer-maintenance/cron-job.printer-maintenance.yml"
