#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# RabbitMQ
kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"
