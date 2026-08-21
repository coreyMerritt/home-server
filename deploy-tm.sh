#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# TM
kubectl apply -f "./namespaces/tm/tm/config-map.tm-global.yml"
kubectl apply -f "./namespaces/tm/tm/config-map.tm-django.yml"
kubectl apply -f "./namespaces/tm/tm/deployment.tm-django.yml"
kubectl apply -f "./namespaces/tm/tm/service.tm-django.yml"
kubectl apply -f "./namespaces/tm/tm/ingress.tm-django.yml"
