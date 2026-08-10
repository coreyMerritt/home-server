#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# Job Listing GUI
kubectl apply -f "./namespaces/job-listing/job-listing-gui/deployment.job-listing-gui.yml"
kubectl apply -f "./namespaces/job-listing/job-listing-gui/service.job-listing-gui.yml"
kubectl apply -f "./namespaces/job-listing/job-listing-gui/ingress.job-listing-gui.yml"
