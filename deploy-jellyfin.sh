#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# Jellyfin
kubectl apply -f "./namespaces/jellyfin/jellyfin/persistent-volume-claim.media-library.yml"
kubectl apply -f "./namespaces/jellyfin/jellyfin/persistent-volume-claim.jellyfin-config.yml"
kubectl apply -f "./namespaces/jellyfin/jellyfin/deployment.jellyfin.yml"
kubectl apply -f "./namespaces/jellyfin/jellyfin/service.jellyfin.yml"
kubectl apply -f "./namespaces/jellyfin/jellyfin/ingress.jellyfin.yml"
kubectl apply -f "./namespaces/jellyfin/jellyfin/cron-job.jellyfin-config-backup.yml"
