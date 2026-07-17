#!/usr/bin/env bash

set -euo pipefail

# General
kubectl apply -f "./namespaces.yml"

# Generate secrets
find . -name '*secrets.yml.template' -o -name '*secrets.yaml.template' | while read -r template; do
  output="${template%.template}"
  echo "Injecting: $template -> $output"
  op inject -i "$template" -o "$output" -f < /dev/null
  kubectl apply -f "$output"
done

# Metrics
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

# Longhorn
helm repo add longhorn https://charts.longhorn.io
helm repo update longhorn
if helm status longhorn -n longhorn-system >/dev/null 2>&1 && \
   [ "$(kubectl get pods -n longhorn-system --no-headers 2>/dev/null | grep -v -c 'Running\|Completed')" -eq 0 ]; then
  echo "Longhorn already installed and healthy, skipping."
else
  echo "Installing/upgrading Longhorn..."
  helm upgrade --install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace
  echo "Waiting for Longhorn pods to become ready..."
  kubectl wait --for=condition=Ready pods --all -n longhorn-system --timeout=300s
fi

# MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.16.1/config/manifests/metallb-native.yaml
kubectl wait --for=condition=Ready pods --all -n metallb-system --timeout=300s
kubectl apply -f ./services/metallb/pool.yml	

# Ingress-xginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update ingress-nginx
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer

# Node Exporter
kubectl apply -f "./services/node-exporter/daemonset.yml"

# Prometheus
kubectl apply -f "./services/prometheus/storageclass.yml"
kubectl apply -f "./services/prometheus/pvc.yml"
kubectl apply -f "./services/prometheus/rbac.yml"
kubectl apply -f "./services/prometheus/configmap.yml"
kubectl apply -f "./services/prometheus/deployment.yml"
kubectl apply -f "./services/prometheus/service.yml"
kubectl apply -f "./services/prometheus/ingress.yml"

# Grafana
kubectl apply -f "./services/grafana/pvc.yml"
kubectl apply -f "./services/grafana/deployment.yml"
kubectl apply -f "./services/grafana/service.yml"
kubectl apply -f "./services/grafana/ingress.yml"

# Job Listing Data Manager
kubectl apply -f "./services/job-listing-data-manager/configmap.yml"
kubectl apply -f "./services/job-listing-data-manager/postgres-pvc.yml"
kubectl apply -f "./services/job-listing-data-manager/postgres-deployment.yml"
kubectl wait --for=condition=Ready pod -l app=postgres -n job-listing --timeout=120s
kubectl apply -f "./services/job-listing-data-manager/postgres-svc.yml"
kubectl apply -f "./services/job-listing-data-manager/pvc.yml"
kubectl apply -f "./services/job-listing-data-manager/deployment.yml"
kubectl apply -f "./services/job-listing-data-manager/svc.yml"
kubectl apply -f "./services/job-listing-data-manager/ingress.yml"

# Job Listing GUI
kubectl apply -f "./services/job-listing-gui/deployment.yml"
kubectl apply -f "./services/job-listing-gui/service.yml"
kubectl apply -f "./services/job-listing-gui/ingress.yml"

# SC2 Data Manager
kubectl apply -f "./services/sc2-data-manager/configmap.yml"
kubectl apply -f "./services/sc2-data-manager/pvc.yml"
kubectl apply -f "./services/sc2-data-manager/deployment.yml"
kubectl apply -f "./services/sc2-data-manager/svc.yml"
kubectl apply -f "./services/sc2-data-manager/ingress.yml"

# Jellyfin
kubectl apply -f "./services/jellyfin/media-pv.yml"
kubectl apply -f "./services/jellyfin/pvc.yml"
kubectl apply -f "./services/jellyfin/deployment.yml"
kubectl apply -f "./services/jellyfin/svc.yml"
kubectl apply -f "./services/jellyfin/ingress.yml"

