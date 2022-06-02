# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # config.vagrant.plugins = ["vagrant-vbguest"] #optional - leaving it in as it's nice, but the ubuntu vagrant box has guest tools preinstalled.

  # Kubernetes Master Server
  config.vm.define "control" do |control|
    control.vm.box = "ubuntu/focal64"
    control.vm.hostname = "control.example.com"
    # "On Linux, Mac OS X and Solaris Oracle VM VirtualBox will only allow IP addresses in 192.168.56.0/21 range to be assigned to host-only adapters."
    # from https://www.virtualbox.org/manual/ch06.html#network_hostonly
    # Host Address Range  192.168.56.1-192.168.63.254 (2046 hosts)

    control.vm.network "private_network", ip: "192.168.56.10"
    control.vm.provider "virtualbox" do |v|
      v.name = "control"
      v.memory = 4096
      v.cpus = 2
    end

    # It looks like the vagrant vm.hostname stanza isn't working effectively. Manually set hostname so that kubernetes' network inferences work correctly
    control.vm.provision "shell", inline: "hostnamectl set-hostname control.example.com"
    control.vm.provision "shell", path: "./setup-userland-and-cri.sh"
    control.vm.provision "shell", path: "./setup-kubernetes-tooling.sh"
    # We are using /etc/hosts for DNS resolution.
    # "If you are using VirtualBox (directly or via Vagrant), you will need to ensure that hostname -i returns a routable IP address. 
    # By default the first interface is connected to a non-routable host-only network. A work around is to modify /etc/hosts"
    # from https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/#pods-are-not-accessible-via-their-service-ip
    control.vm.provision "shell", inline: "echo 192.168.56.11 worker1.example.com >> /etc/hosts"
    control.vm.provision "shell", inline: "echo 192.168.56.12 worker2.example.com >> /etc/hosts"
    control.vm.provision "shell", inline: "echo 192.168.56.13 worker3.example.com >> /etc/hosts"
    control.vm.provision "shell", inline: "echo 192.168.56.14 worker4.example.com >> /etc/hosts"
    control.vm.provision "shell", inline: "echo 192.168.56.10 control.example.com >> /etc/hosts"
    control.vm.provision "shell", inline: "kubeadm init --apiserver-advertise-address 192.168.56.10 --control-plane-endpoint 192.168.56.10 --pod-network-cidr 10.10.0.0/20"
    control.vm.provision "shell", inline: "mkdir /home/vagrant/.kube && cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config && chown -R vagrant:vagrant /home/vagrant/.kube && echo 'export KUBECONFIG=${HOME}/.kube/config'>> /home/vagrant/.bashrc"
    control.vm.provision "shell", path: "./setup-flannel.sh", privileged: false
  end

  NodeCount = 3

#   Kubernetes Worker Nodes
  (1..NodeCount).each do |i|
    config.vm.define "worker#{i}" do |workernode|
      workernode.vm.box = "ubuntu/focal64"
      workernode.vm.hostname = "worker#{i}.example.com"
      workernode.vm.network "private_network", ip: "192.168.56.1#{i}"
      workernode.vm.provider "virtualbox" do |v|
        v.name = "worker#{i}"
        v.memory = 4096
        v.cpus = 2
      end
      workernode.vm.provision "shell", inline: "hostnamectl set-hostname worker#{i}.example.com"
      workernode.vm.provision "shell", inline: "echo 192.168.56.11 worker1.example.com >> /etc/hosts"
      workernode.vm.provision "shell", inline: "echo 192.168.56.12 worker2.example.com >> /etc/hosts"
      workernode.vm.provision "shell", inline: "echo 192.168.56.13 worker3.example.com >> /etc/hosts"
      workernode.vm.provision "shell", inline: "echo 192.168.56.14 worker4.example.com >> /etc/hosts"
      workernode.vm.provision "shell", inline: "echo 192.168.56.10 control.example.com >> /etc/hosts"
      workernode.vm.provision "shell", path: "./setup-userland-and-cri.sh"
      workernode.vm.provision "shell", path: "./setup-kubernetes-tooling.sh"
      workernode.vm.provision "shell", inline: "echo Remember to initialise your worker node. The right command should have flow by in the control output."
    end
  end
  
end