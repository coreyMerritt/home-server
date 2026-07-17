#!/usr/bin/env bash

set -euo pipefail

# Ensure our starting dir is standardized
script_dir="$(dirname $(readlink -f $0))"
cd "$script_dir"

# Namespaces
dir_path="./namespaces"
namespace_filenames="$(ls ${dir_path}/)"
for namespace_filename in $namespace_filenames; do
  kubectl apply -f "${dir_path}/${namespace_filename}"
done

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

# Global Resources
dir_path="./global"
global_resource_filenames="$(ls ${dir_path}/)"
for resource_filename in $global_resource_filenames; do
  kubectl apply -f "${dir_path}/${resource_filename}"
done

# Metrics
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

# Longhorn
helm repo add longhorn https://charts.longhorn.io
helm repo update longhorn
if helm status longhorn -n longhorn-system >/dev/null 2>&1 && \
[[ "$(kubectl get pods -n longhorn-system --no-headers 2>/dev/null | grep -v -c 'Running\|Completed')" -eq 0 ]]; then
  echo "Longhorn already installed and healthy, skipping."
else
  echo "Installing/upgrading Longhorn..."
  helm upgrade \
    --install "longhorn" "longhorn/longhorn" \
    --namespace "longhorn-system" \
    --create-namespace
  echo "Waiting for Longhorn pods to become ready..."
  kubectl wait \
    --all \
    --timeout=300s \
    --for=condition=Ready "pods" \
    --namespace "longhorn-system" 
fi

# MetalLB
kubectl apply -f "https://raw.githubusercontent.com/metallb/metallb/v0.16.1/config/manifests/metallb-native.yaml"
kubectl wait \
  --all \
  --timeout=300s \
  --for=condition=Ready "pods" \
  --namespace "metallb-system" 
kubectl apply -f "./services/metallb/ip-address-pool.homelab-pool.yml"
kubectl apply -f "./services/metallb/l2-advertisement.homelab-l2.yml"

# Ingress-xginx
helm repo add "ingress-nginx" "https://kubernetes.github.io/ingress-nginx"
helm repo update "ingress-nginx"
helm upgrade \
  --install "ingress-nginx" "ingress-nginx/ingress-nginx" \
  --namespace "ingress-nginx" \
  --create-namespace \
  --set "controller.service.type=LoadBalancer"

# Node Exporter
kubectl apply -f "./services/node-exporter/daemon-set.node-exporter.yml"

# Jellyfin
kubectl apply -f "./services/jellyfin/persistent-volume-claim.media-library.yml"
kubectl apply -f "./services/jellyfin/persistent-volume-claim.jellyfin-config.yml"
kubectl apply -f "./services/jellyfin/deployment.jellyfin.yml"
kubectl apply -f "./services/jellyfin/service.jellyfin.yml"
kubectl apply -f "./services/jellyfin/ingress.jellyfin.yml"
kubectl apply -f "./services/jellyfin/cron-job.jellyfin-config-backup.yml"

# Job Listing Data Manager
kubectl apply -f "./services/job-listing-data-manager/config-map.job-listing-data-manager-config.yml"
kubectl apply -f "./services/job-listing-data-manager/persistent-volume-claim.postgres-data.yml"
kubectl apply -f "./services/job-listing-data-manager/deployment.postgres.yml"
kubectl wait --for=condition=Ready pod -l app=postgres -n job-listing --timeout=120s
kubectl apply -f "./services/job-listing-data-manager/service.postgres.yml"
kubectl apply -f "./services/job-listing-data-manager/persistent-volume-claim.job-listing-data-manager-config.yml"
kubectl apply -f "./services/job-listing-data-manager/deployment.job-listing-data-manager.yml"
kubectl apply -f "./services/job-listing-data-manager/service.job-listing-data-manager.yml"
kubectl apply -f "./services/job-listing-data-manager/ingress.job-listing-data-manager.yml"
kubectl apply -f "./services/job-listing-data-manager/cron-job.job-listing-data-manager-config-backup.yml"
kubectl apply -f "./services/job-listing-data-manager/cron-job.job-listing-data-manager-postgres-backup.yml"

# Job Listing GUI
kubectl apply -f "./services/job-listing-gui/deployment.job-listing-gui.yml"
kubectl apply -f "./services/job-listing-gui/service.job-listing-gui.yml"
kubectl apply -f "./services/job-listing-gui/ingress.job-listing-gui.yml"

# Prometheus
kubectl apply -f "./services/prometheus/persistent-volume-claim.prometheus-data.yml"
kubectl apply -f "./services/prometheus/service-account.prometheus.yml"
kubectl apply -f "./services/prometheus/cluster-role.prometheus.yml"
kubectl apply -f "./services/prometheus/cluster-role-binding.prometheus.yml"
kubectl apply -f "./services/prometheus/config-map.prometheus-config.yml"
kubectl apply -f "./services/prometheus/deployment.prometheus.yml"
kubectl apply -f "./services/prometheus/service.prometheus.yml"
kubectl apply -f "./services/prometheus/ingress.prometheus.yml"
kubectl apply -f "./services/prometheus/cron-job.prometheus-data-backup.yml"

# Grafana
kubectl apply -f "./services/grafana/persistent-volume-claim.grafana-data.yml"
kubectl apply -f "./services/grafana/deployment.grafana.yml"
kubectl apply -f "./services/grafana/service.grafana.yml"
kubectl apply -f "./services/grafana/ingress.grafana.yml"
kubectl apply -f "./services/grafana/cron-job.grafana-data-backup.yml"

# SC2 Data Manager
kubectl apply -f "./services/sc2-data-manager/config-map.sc2-data-manager.yml"
kubectl apply -f "./services/sc2-data-manager/persistent-volume-claim.sc2-data-manager-db.yml"
kubectl apply -f "./services/sc2-data-manager/persistent-volume-claim.sc2-data-manager-game-files.yml"
kubectl apply -f "./services/sc2-data-manager/persistent-volume-claim.sc2-data-manager-config.yml"
kubectl apply -f "./services/sc2-data-manager/deployment.sc2-data-manager.yml"
kubectl apply -f "./services/sc2-data-manager/service.sc2-data-manager.yml"
kubectl apply -f "./services/sc2-data-manager/ingress.sc2-data-manager.yml"
kubectl apply -f "./services/sc2-data-manager/cron-job.sc2-data-manager-config-backup.yml"
kubectl apply -f "./services/sc2-data-manager/cron-job.sc2-data-manager-db-backup.yml"
kubectl apply -f "./services/sc2-data-manager/cron-job.sc2-data-manager-game-files-backup.yml"
