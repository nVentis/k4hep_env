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

    mamba install gcc numpy matplotlib seaborn pandas -y
    mamba install pytorch torchvision torchaudio cpuonly -c pytorch -y
    mamba install pyg -c pyg -y
    yes | pip install normflows
fi