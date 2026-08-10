#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# Vars
resource_kinds=(
  "cronjob"
  "daemonset"
  "deployment"
  "statefulset"
)

# Functions
restart_all_of_kind() {
  local kind="$1"
  kubectl get "$kind" -A -o jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name}{"\n"}{end}' \
    | while read -r namespace name; do
        echo "Restarting ${kind}/${name} in namespace ${namespace}..."
        kubectl -n "$namespace" rollout restart "${kind}/${name}"
      done
}

# Entrypoint
for kind in "${resource_kinds[@]}"; do
  restart_all_of_kind "$kind"
done
