#!/bin/bash -el
# script that runs on both the worker and controller nodes. This means this is a superset of all needed
# https://kubernetes.io/docs/setup/production-environment/container-runtimes
if ! [ $USER = root ]
then
  echo run this script as root
  exit 3
fi

# "For a cluster you're managing yourself, the officially supported tool for deploying Kubernetes is kubeadm."
# from https://kubernetes.io/docs/setup/#production-environment

swapoff -a

# For the control node
# https://kubernetes.io/docs/reference/ports-and-protocols/
ufw allow 6443
ufw allow 2379
ufw allow 2380
ufw allow 10250
ufw allow 10259
ufw allow 10257
ufw allow 10250

# For workers
ufw allow from any to any proto tcp port 30000:32767


# Next is an OCI compliant runtime. 
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd refers us to 
# https://github.com/containerd/containerd/blob/main/docs/getting-started.md to get started with containerd
# option 2 is to use apt on ubuntu https://github.com/containerd/containerd/blob/main/docs/getting-started.md#option-2-from-apt-get-or-dnf
# This redirects us to https://docs.docker.com/engine/install/ubuntu/, as containerd prebuilt binaries are distributed by docker.
# We want our script to succeed irrespective of whether Ubuntu decide to prepackage docker or not.
apt-get remove docker docker-engine docker.io containerd runc || true 

apt-get update
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

mkdir -p /etc/apt/keyrings 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# The containerd github instructions we're looking at and the kubernetes instructions we've forked from 
# (https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd-systemd) seem to imply that 
# k8s is expecting a default config file but with one change.
# In the   [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options] section, SystemdCgroup should be true
containerd config default > /etc/containerd/config.toml
sed -i s/SystemdCgroup = false/SystemdCgroup = true/ /etc/containerd/config.toml

# Apply changes
systemctl restart containerd
