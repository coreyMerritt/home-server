#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# Job Listing Data Manager
kubectl apply -f "./namespaces/job-listing/job-listing-data-manager/config-map.job-listing-data-manager-config.yml"
kubectl apply -f "./namespaces/job-listing/job-listing-data-manager/persistent-volume-claim.postgres-data.yml"
kubectl apply -f "./namespaces/job-listing/job-listing-data-manager/deployment.postgres.yml"
kubectl wait --for=condition=Ready pod -l app=postgres -n job-listing --timeout=120s
kubectl apply -f "./namespaces/job-listing/job-listing-data-manager/service.postgres.yml"
kubectl apply -f "./namespaces/job-listing/job-listing-data-manager/persistent-volume-claim.job-listing-data-manager-config.yml"
kubectl apply -f "./namespaces/job-listing/job-listing-data-manager/deployment.job-listing-data-manager.yml"
kubectl apply -f "./namespaces/job-listing/job-listing-data-manager/service.job-listing-data-manager.yml"
kubectl apply -f "./namespaces/job-listing/job-listing-data-manager/ingress.job-listing-data-manager.yml"
kubectl apply -f "./namespaces/job-listing/job-listing-data-manager/cron-job.job-listing-data-manager-config-backup.yml"
kubectl apply -f "./namespaces/job-listing/job-listing-data-manager/cron-job.job-listing-data-manager-postgres-backup.yml"
