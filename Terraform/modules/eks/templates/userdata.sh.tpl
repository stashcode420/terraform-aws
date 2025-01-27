#!/bin/bash
set -e

# Bootstrap and join the cluster
/etc/eks/bootstrap.sh ${cluster_name} \
    --b64-cluster-ca ${cluster_ca_data} \
    --apiserver-endpoint ${cluster_endpoint} \
    --dns-cluster-ip ${cluster_dns_ip} \
    --kubelet-extra-args "%{ if node_labels != "" }--node-labels=${node_labels}%{ endif }%{ if node_taints != "" } --register-with-taints=${node_taints}%{ endif }"