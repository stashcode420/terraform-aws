# modules/eks/templates/userdata.sh.tpl
#!/bin/bash
set -o xtrace

/etc/eks/bootstrap.sh ${cluster_name} \
  --b64-cluster-ca ${cluster_ca_data} \
  --apiserver-endpoint ${cluster_endpoint} \
  --dns-cluster-ip ${cluster_dns_ip} \
  --container-runtime containerd \
  --kubelet-extra-args "--node-labels=${node_labels}${node_taints != "" ? format(",taints=%s", node_taints) : ""} ${bootstrap_extra_args}"