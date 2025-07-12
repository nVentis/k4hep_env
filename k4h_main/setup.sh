#!/bin/bash

# Setup remote SSH access
yum -y update
yum -y install openssh-server wget nano tree pv htop

mkdir -p $HOME/.ssh
mkdir -p /var/run/sshd
ssh-keygen -A
rm -rf /run/nologin

# Source env file
. /root/.env

# Problems (15s delays) with connecting via SSH on WSL2 can be alleviated with changes to sshd_config
# Further issues may be related to a weird MTU value, in which case values around MTU=1350 on eth0 might help

sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config

echo "Setting up the environment"

# Setup SSH
if [ ! -z $SSH_PUBLIC_KEY ]; then
    echo "Setting up SSH"
    touch $HOME/.ssh/authorized_keys
    cat >> $HOME/.ssh/authorized_keys <<EOF
$SSH_PUBLIC_KEY
EOF

    chmod 700 $HOME/.ssh
    chmod 600 $HOME/.ssh/authorized_keys
fi

# Increase CVMFS cache size to 32 GB
sed 's/^CVMFS_QUOTA_LIMIT=.*/CVMFS_QUOTA_LIMIT=32000/' -i /etc/cvmfs/default.local
