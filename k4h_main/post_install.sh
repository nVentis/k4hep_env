#!/bin/bash

# File intended for setting up dev container and DESY NAF

export PYTHON_ENV_NAME=py311
export PYTHON_VERSION="3.11"
export CONDA_ROOT=$HOME/miniforge3
export SETUP_ALL="true"

export ON_NAF="false"
if [[ $( cat /etc/hostname ) == *"desy.de"* ]]; then
    ON_NAF="true"
    SETUP_ALL="false"

    CONDA_ROOT=/nfs/dust/ilc/user/bliewert/miniconda3
else
    # Link home
    mkdir -p /afs/desy.de/user/b
    ln -s $HOME /afs/desy.de/user/b/bliewert

    # Link data samples to bind mount (/nfs)
    mkdir -p /pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged
    ln -s /nfs/dust/ilc/user/bliewert/500-TDR_ws/ /pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged/500-TDR_ws
fi

if [ ! -f "$HOME/nfs" ]; then
    ln -s /nfs/dust/ilc/user/bliewert $HOME/nfs
fi

export PYTHON_ENV_ROOT=$CONDA_ROOT/envs/$PYTHON_ENV_NAME

############## BEGIN DEPENDENCY CHECK ##############

if [ $SETUP_ALL == "true" ]; then
    source /cvmfs/ilc.desy.de/key4hep/key4hep_latest_setup.sh

    # Python environment
    conda activate py311
    pip install ipywidgets  
fi

# Setup LCIO
echo "Setting up LCIO---"

if [ -d "$HOME/public/ILCSoft/LCIO/build" ]; then
    echo "Skipping LCIO (already built)"
else
    mkdir -p $HOME/public/ILCSoft/LCIO/build && cd $HOME/public/ILCSoft/LCIO/build

    cmake -DBUILD_ROOTDICT=ON -DCMAKE_CXX_STANDARD=17 ..
    make -j 4 install
fi

# Link such that LCIO is available in the python environment
if [ $ON_NAF == "false" ]; then
    ln -s /root/public/ILCSoft/LCIO/build/_deps/sio_extern-src/python $HOME/public/ILCSoft/LCIO/python
fi

if [[ $(conda env config vars list) == *"LD_LIBRARY_PATH"* ]]; then
    echo "LD_LIBRARY_PATH already set"
else
    conda env config vars set LD_LIBRARY_PATH=$HOME/public/ILCSoft/LCIO/build/lib64
fi

# Get ILDConfig
if [ -d "/afs/desy.de/user/b/bliewert/public/ILCSoft/ILDConfig" ]; then
    echo "Skipping ILDConfig (already exists)"
else
    cd /afs/desy.de/user/b/bliewert/public
    git clone git clone https://github.com/iLCSoft/ILDConfig.git
fi

# Unpack weights
if [ -f " /afs/desy.de/user/b/bliewert/public/ILCSoft/ILDConfig/LCFIPlusConfig/lcfiweights/6q500_v04_p00_ildl5_c0_bdt.class.C" ]; then
    echo "Skipping LCFIPlus weights (already exist)"
else
    echo "Unpacking LCFIPlus weights..."

    cd /afs/desy.de/user/b/bliewert/public/ILCSoft/ILDConfig/LCFIPlusConfig/lcfiweights
    tar -xvzf 6q500_v04_p00_ildl5.tar.gz
fi


# bashrc commands
if [[ $( cat $HOME/.bashrc ) != *"sk4h="* ]]; then
    echo "alias sk4h='source /cvmfs/ilc.desy.de/key4hep/key4hep_latest_setup.sh'" >> $HOME/.bashrc
fi

# Clone: ZHH
echo "Setting up ZHH..."

mkdir -p ${HOME}/public/MarlinWorkdirs
cd ${HOME}/public/MarlinWorkdirs

git clone https://github.com/nVentis/ZHH.git

# Clone: pyhepcommon
echo "Setting up pyhepcommon..."

cd ${HOME}/public/MarlinWorkdirs

git clone https://github.com/nVentis/pyhepcommon.git

# Linking
if [ ! -f $PYTHON_ENV_ROOT/lib/python$PYTHON_VERSION/site-packages/zhh.pth ]; then
    echo "${HOME}/public/MarlinWorkdirs/ZHH" >> $PYTHON_ENV_ROOT/lib/python$PYTHON_VERSION/site-packages/zhh.pth
fi

if [ ! -f $PYTHON_ENV_ROOT/lib/python$PYTHON_VERSION/site-packages/lcio.pth ]; then
    echo "${HOME}/public/ILCSoft/LCIO/python" >> $PYTHON_ENV_ROOT/lib/python$PYTHON_VERSION/site-packages/lcio.pth
fi

if [ ! -f $PYTHON_ENV_ROOT/lib/python$PYTHON_VERSION/site-packages/pyhepcommon.pth ]; then
    echo "${HOME}/public/MarlinWorkdirs/pyhepcommon" >> $PYTHON_ENV_ROOT/lib/python$PYTHON_VERSION/site-packages/pyhepcommon.pth
fi
