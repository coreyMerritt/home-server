#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

resource_kinds=(
  "deployment"
  "statefulset"
  "daemonset"
)

restart_all_of_kind() {
  local kind="$1"
  kubectl get "$kind" -A -o jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name}{"\n"}{end}' \
    | while read -r namespace name; do
        echo "Restarting ${kind}/${name} in namespace ${namespace}..."
        kubectl rollout restart "${kind}/${name}" -n "$namespace"
      done
}

for kind in "${resource_kinds[@]}"; do
  restart_all_of_kind "$kind"
done
