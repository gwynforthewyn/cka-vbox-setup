# Intended usage
git clone this repo
then vagrant up

# PreReqs
Install Virtualbox and Vagrant! I don't want to provide instructions as this is OS specific.

[VirtualBox Instructions](https://www.virtualbox.org/wiki/Downloads) 
[Vagrant Instructions](https://www.vagrantup.com)

I'm running virtualbox on fedora; PRs are welcome to correct platform-specific nuances.

# Why Virtualbox/Vagrant, not Containers, for hosting Kubernetes?
Containers all share a kernel, which means they all share IPTables, and k8s makes heavy usage of IPTables. I'm not certain how important having an isolated set of IP Tables chains is, but I'm not taking any chances.

# Why Ubuntu Inside Virtualbox?
Because Canonical offers [official Vagrant boxes](https://app.vagrantup.com/ubuntu/boxes/focal64) and I don't want to have a compromised system because some toolbag uploaded a whacky box to vagrant.