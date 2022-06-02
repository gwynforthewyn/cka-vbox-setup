#!/bin/bash -el

# The documentation in the README is a little sparse on one detail. https://github.com/flannel-io/flannel
# The setup instructions read:
# 1. Make sure a flanneld binary exists at /opt/bin/flanneld on each node
# 2. kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
# This seems to be misleading; if you are applying the kubectl command, I have not seen a need to have flannel
# installed on the host.
# In the interests of completeness, the compilation instructions for flanneld on the host are in this repository as a script, 
# but the real clue for how to run flannel appears to be the following error from the kubelet:
#   Warning  FailedCreatePodSandBox  22s   kubelet            Failed to create pod sandbox: rpc error: \
#     code = Unknown desc = failed to setup network for sandbox "ed1b07b0560bcc58a1d1eae091ae1e96fe2e873beaf818d100b1c5aca532257d": \ 
#     plugin type="flannel" failed (add): open /run/flannel/subnet.env: no such file or directory
# The /run/flannel directory exists on the host OS of workers and controller, and a subnet.env file must exist there for 
# Flannel to function correctly.

# You can write this file directly. This is an example of how:
# cd /home/vagrant
## Make sure the cidr in this sed command matches your network pod cidr. To find that, you can use kubectl dump-info and grep for cidr in the output.
# curl --silent https://raw.githubusercontent.com/flannel-io/flannel/master/dist/sample_subnet.env | sed 's/10.1.0.0\/16/192.168.56.1\/21/' > subnet.env
# sudo mkdir /run/flannel
# sudo mv subnet.env /run/flannel/subnet.env

# However, the most authoritative way to write out the flannel subnet.env is to add the flag '--pod-network-cidr' to your kubeadm command, as is done
# in this repository's Vagrantfile. flannel will interrogate kubernetes, find this information, and automatically write its own subnet.env file

cd /home/vagrant
# If you use custom podCIDR (not 10.244.0.0/16) you first need to download the above manifest and modify the network to match your one.
# - from https://github.com/flannel-io/flannel/blob/master/README.md 
# The network assignment here matches the --pod-cidr in the Vagrantfile
curl --silent https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml | sed 's/10.244.0.0\/16/10.10.0.0\/20/'  > flannel.yml
kubectl apply -f /home/vagrant/flannel.yml