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

if [ $APP_ENV == "prod" ]; then
    echo "Setting up production environment"
    
    if [ $PYTH_INSTALL ]; then
        # Install conda, Python etc.
        cd ~
        wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
        bash Miniforge3-Linux-x86_64.sh -b -p $HOME/miniforge3
        eval "$($HOME/miniforge3/bin/conda shell.bash hook)"
        conda init
        rm -f Miniforge3-Linux-x86_64.sh
    fi

    # Setup environment
    if [ $PYTH_ENV_INSTALL == "true" ]; then
        echo "Installing Python environment"

        mamba create -n $PYTH_ENV_NAME python=$PYTH_ENV_VER -y
        conda activate $PYTH_ENV_NAME

        mamba install gcc cmake root numpy matplotlib seaborn pandas -y
        if [ $PYTH_TORCH == "true" ]; then
            if [ $TORCH_GPU_SUPPORT == "true" ]; then
                # Install nvidia container toolkit https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#configuring-docker
                curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo

                sudo yum install -y nvidia-container-toolkit

                pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
            else
                mamba install pytorch torchvision torchaudio cpuonly -c pytorch -y
            fi

            # For PyTorch Geometric support: 
            if [ $PYTH_TORCH_GEOMETRIC == "true" ]; then
                mamba install pyg -c pyg -y
                #yes | pip install normflows
            fi
        fi
    fi

    # Save some config in .bashrc
    echo "export USE_CVMFS=$USE_CVMFS" >> $HOME/.bashrc

    # Setup SSH
    echo "Setting up SSH"
    touch $HOME/.ssh/authorized_keys
    cat >> $HOME/.ssh/authorized_keys <<EOF
$SSH_PUBLIC_KEY
EOF

    chmod 700 $HOME/.ssh
    chmod 600 $HOME/.ssh/authorized_keys

    # Increase CVMFS cache size to 100 GB
    cat << EOF >> /etc/cvmfs/default.local
    
CVMFS_QUOTA_LIMIT=100000
EOF

    # Setup ILCSoft
    cd ~
    mkdir ILCSoft
    cd ILCSoft

    git clone https://github.com/iLCSoft/LCIO.git
    git clone https://github.com/iLCSoft/ILDConfig.git





fi