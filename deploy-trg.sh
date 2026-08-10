#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# TRG
kubectl apply -f "./namespaces/trg/trg/config-map.trg.yml"
kubectl apply -f "./namespaces/trg/trg/deployment.trg.yml"
