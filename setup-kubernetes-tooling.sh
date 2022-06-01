#!/bin/bash -el
# kubeadm installation instructions as on
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# run this script with sudo

if ! [ $USER = root ]
then
	echo run this script with sudo
	exit 3
fi


# The kubernetes instructions at https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd-systemd
# have another detail.
# "When using kubeadm, manually configure the cgroup driver for kubelet." 
# This links to https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/configure-cgroup-driver/#configuring-the-kubelet-cgroup-driver
# This applies to 1.21.0 and below. We're at 1.24, so no worries!

# Now we shall start with https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
apt-get update
apt-get install -y apt-transport-https ca-certificates curl

curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
# This references xenial, but I think it's benign even though we're using focal-fossa
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl