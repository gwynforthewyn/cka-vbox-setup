#!/bin/bash -el

# The documentation in the README is a little sparse on one detail. https://github.com/flannel-io/flannel
# The setup instructions read:
# 1. Make sure a flanneld binary exists at /opt/bin/flanneld on each node
# 2. kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
# This seems to be misleading; if you are applying the kubectl command, I have not seen a need to have flannel
# installed on the host.
# In the interests of completeness, the compilation instructions for flanneld on the host are in this script, 

cd /home/vagrant/
# Step 1 indicates installing in the userland of the host OS. There's no apt package I can see for flanneld. 
# There are build instructions at https://github.com/flannel-io/flannel/blob/master/Documentation/building.md#building-manually
export GOPATH=/home/vagrant/go/
echo 'GOPATH=/home/vagrant/go' >> /home/vagrant/.bashrc
mkdir -p "${GOPATH}/src"

#  This script runs as the Vagrant user, so we need some sudo privileges.
sudo apt-get install -y linux-libc-dev gcc make

# The version of golang in the apt repositories is 1.13. Most of the modules being installed require >1.16, so we shall
# manually install golang

curl -O https://go.dev/dl/go1.18.3.linux-amd64.tar.gz -L --silent
sudo tar -C /usr/local -xzf go1.18.3.linux-amd64.tar.gz

export PATH=$PATH:/usr/local/go/bin
echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/vagrant/.bashrc


# Now that we have the language installed, let's get on with building and compiling flannel
cd $GOPATH/src
git clone https://github.com/flannel-io/flannel.git
cd flannel
CGO_ENABLED=1 make dist/flanneld

# I have a soft spot for /usr/local over /opt
sudo mkdir /opt/bin
sudo mv dist/flanneld /opt/bin
sudo chmod +x /opt/bin/flanneld

echo "flanneld compiled and placed in /opt/bin/flanneld. Either start it directly, or write a systemd unit file for it."
echo "Note that you will need to write a file /run/flannel/subnet.env with your network details in it. See setup-flannel.sh for details."
