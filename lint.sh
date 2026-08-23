#!/usr/bin/env bash

set -xeuo pipefail

resource_names=(
  "pvc.yml"
  "cron-job.yml"
  "config-map.yml"
  "namespace.yml"
  "secret.dockerconfigjson.yml.template"
  "secret.opaque.yml.template"
  "deployment.yml"
  "service.yml"
  "job.yml"
  "ingress.yml"
  "secret.tls.yml.template"
  "ip-address-pool.yml"
  "l2-advertisement.yml"
  "daemon-set.yml"
  "service-account.yml"
  "cluster-role-binding.yml"
  "cluster-role.yml"
)

cmd=(find . -name "*.yml*")
cmd_str="find . -name \"*.yml*\" | grep -v global"

for resource_name in "${resource_names[@]}"; do
  cmd_str+=" | grep -v \"/${resource_name}\\\$\""
done

eval ! "$cmd_str"

echo -e "\n\tNaming conventions are followed.\n"
