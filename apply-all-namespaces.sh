#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# Namespaces
dir_path="./namespaces"
namespace_filepaths="$(find namespaces -name namespace.* -type f)"
for namespace_filepath in $namespace_filepaths; do
  kubectl apply -f "$namespace_filepath"
done
