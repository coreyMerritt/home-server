#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# Global Resources
dir_path="global"
global_resource_filenames="$(ls ${dir_path}/)"
for resource_filename in $global_resource_filenames; do
  kubectl apply -f "${dir_path}/${resource_filename}"
done
