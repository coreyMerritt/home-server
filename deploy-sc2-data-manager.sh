#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# SC2 Data Manager
kubectl apply -f "./namespaces/sc2/sc2-data-manager/config-map.sc2-data-manager.yml"
kubectl apply -f "./namespaces/sc2/sc2-data-manager/persistent-volume-claim.sc2-data-manager-db.yml"
kubectl apply -f "./namespaces/sc2/sc2-data-manager/persistent-volume-claim.sc2-data-manager-game-files.yml"
kubectl apply -f "./namespaces/sc2/sc2-data-manager/persistent-volume-claim.sc2-data-manager-config.yml"
kubectl apply -f "./namespaces/sc2/sc2-data-manager/deployment.sc2-data-manager.yml"
kubectl apply -f "./namespaces/sc2/sc2-data-manager/service.sc2-data-manager.yml"
kubectl apply -f "./namespaces/sc2/sc2-data-manager/ingress.sc2-data-manager.yml"
kubectl apply -f "./namespaces/sc2/sc2-data-manager/cron-job.sc2-data-manager-config-backup.yml"
kubectl apply -f "./namespaces/sc2/sc2-data-manager/cron-job.sc2-data-manager-db-backup.yml"
kubectl apply -f "./namespaces/sc2/sc2-data-manager/cron-job.sc2-data-manager-game-files-backup.yml"
