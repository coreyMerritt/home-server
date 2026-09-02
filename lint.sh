#!/usr/bin/env bash

set -xeuo pipefail

resource_names=(
  "cluster-role.yml"
  "cluster-role-binding.yml"
  "config-map.yml"
  "cron-job.yml"
  "daemon-set.yml"
  "deployment.yml"
  "ingress.yml"
  "ip-address-pool.yml"
  "job.yml"
  "l2-advertisement.yml"
  "namespace.yml"
  "pvc.yml"
  "role.yml"
  "role-binding.yml"
  "secret.dockerconfigjson.yml.template"
  "secret.opaque.yml.template"
  "secret.tls.yml.template"
  "service.yml"
  "stateful-set.yml"
  "service-account.yml"
)

cmd=(find . -name "*.yml*")
cmd_str="find . -name \"*.yml*\" | grep -v global"

for resource_name in "${resource_names[@]}"; do
  cmd_str+=" | grep -v \"/${resource_name}\\\$\""
done

eval ! "$cmd_str"

echo -e "\n\tNaming conventions are followed.\n"
