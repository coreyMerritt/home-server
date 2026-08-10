#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# Node Exporter
kubectl apply -f "./namespaces/observability/node-exporter/daemon-set.node-exporter.yml"
