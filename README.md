# Intended usage
git clone https://github.com/gwynforthewyn/cka-vbox-setup.git && vagrant up

## post-vagrant-up notes
1. You still need to install a network plugin
1. Your correct `kubeadm init` command  for the workers will have flown by in the control box's stdout. You can search history for the string 'control' to find the right stdout stream; you can regenerate the command with `vagrant ssh control` followed by `kubeadm token create --print-join-command` if you hate scrolling.

## PreReqs
Install Virtualbox and Vagrant!

[VirtualBox Instructions](https://www.virtualbox.org/wiki/Downloads) 
[Vagrant Instructions](https://www.vagrantup.com)

I'm running virtualbox on fedora; PRs are welcome to correct platform-specific nuances.

## Why Virtualbox/Vagrant, not Containers, for hosting Kubernetes?
Containers all share a kernel, which means they all share IPTables, and k8s makes heavy usage of IPTables. I'm not certain how important having an isolated set of IP Tables chains is, but I'm not taking any chances.

## Why Ubuntu Inside Virtualbox?
Because Canonical offers [official Vagrant boxes](https://app.vagrantup.com/ubuntu/boxes/focal64) and I don't want to have a compromised system because some toolbag uploaded a whacky box to vagrant.

## Flannel Installation
Flannel is tied to the kubeadm init argument --pod-cidr. Details are in the setup-flannel.sh script. 

It's not clear to me whether the instructions from flannel upstream to run flanneld on the host are actually necessary. If they are, compile-flanneld.sh will get you up and running.

## Experimenting
This is a sort of lab environment. If you want to mess around with flannel, or any pods or whatever, `kubectl delete -f <path/to/the/resource.yml>` will rescue you regularly.

## Fragility
There's an explicit reference to the virtualbox device ID for the internal network interface managing the host-only network in setup-flannel.sh. Do with it what you will.