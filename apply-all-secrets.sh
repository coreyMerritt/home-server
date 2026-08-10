#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# All Services' Secrets
find . -name '*secret.*.yml.template' -o -name '*secret.*.yaml.template' | while read -r template; do
  output="${template%.template}"
  echo "Injecting: $template -> $output"
  op inject \
    --force \
    --in-file "$template" \
    --out-file "$output"
  kubectl apply -f "$output"
  rm -rf "$output"
done
