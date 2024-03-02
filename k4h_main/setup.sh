#!/bin/bash

# Setup remote SSH access
sudo yum -y install openssh-server wget nano

mkdir -p /var/run/sshd
ssh-keygen -A

if [ $APP_ENV == "prod" ]; then
    # Install conda, Python etc.
    cd ~
    wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
    bash Miniforge3-Linux-x86_64.sh -b -p $HOME/miniforge3
    eval "$($HOME/miniforge3/bin/conda shell.bash hook)"
    conda init
    rm -f Miniforge3-Linux-x86_64.sh

    # Setup environment
    mamba create -n graphjet_pyg python=3.11 -y
    conda activate graphjet_pyg

    mamba install gcc cmake root numpy matplotlib seaborn pandas -y
    if [ $TORCH_GPU_SUPPORT == "true" ]; then
        # Install nvidia container toolkit https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#configuring-docker
        curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
        sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo

        sudo yum install -y nvidia-container-toolkit

        pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
    else
        mamba install pytorch torchvision torchaudio cpuonly -c pytorch -y
    fi

    # For GPU support: 
    mamba install pyg -c pyg -y
    yes | pip install normflows
fi