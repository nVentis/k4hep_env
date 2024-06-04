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
fi

export PYTHON_ENV_ROOT=$CONDA_ROOT/envs/$PYTHON_ENV_NAME

if [ $SETUP_ALL == "true" ]; then
    source /cvmfs/ilc.desy.de/key4hep/key4hep_latest_setup.sh

    # Link home
    mkdir -p /afs/desy.de/user/b
    ln -s $HOME /afs/desy.de/user/b/bliewert

    # Python environment
    conda activate py311
    pip install ipywidgets

    # Clone and add to python env: LCIO
    echo "Setting up LCIO"

    mkdir -p $HOME/ILCSoft/LCIO/build
    cd $HOME/ILCSoft/LCIO/build

    cmake -DBUILD_ROOTDICT=ON -DCMAKE_CXX_STANDARD=17 ..
    make -j 4 install

    # Link such that LCIO is available in the python environment
    ln -s /root/ILCSoft/LCIO/build/_deps/sio_extern-src/python $HOME/ILCSoft/LCIO/python
    
    if [[ $(conda env config vars list) == *"LD_LIBRARY_PATH"* ]]; then
        echo "LD_LIBRARY_PATH already set"
    else
        conda env config vars set LD_LIBRARY_PATH=$HOME/ILCSoft/LCIO/build/lib64
    fi
    

fi

# Link directories
if [ $ON_NAF == "false" ]; then
    mkdir -p /pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged
    ln -s /nfs/dust/ilc/user/bliewert/500-TDR_ws/ /pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged/500-TDR_ws
fi


# bashrc commands
if [[ $( cat $HOME/.bashrc ) != *"sk4h="* ]]; then
    echo "alias sk4h='source /cvmfs/ilc.desy.de/key4hep/key4hep_latest_setup.sh'" >> $HOME/.bashrc
fi

# Clone: ZHH
echo "Setting up LCIO"

mkdir -p ${HOME}/public/MarlinWorkdirs
cd ${HOME}/public/MarlinWorkdirs

git clone https://github.com/nVentis/ZHH.git

# Clone: pyhepcommon
echo "Setting up pyhepcommon"

cd ${HOME}/public/MarlinWorkdirs

git clone https://github.com/nVentis/pyhepcommon.git

# Linking
if [ ! -f $PYTHON_ENV_ROOT/lib/python$PYTHON_VERSION/site-packages/zhh.pth ]; then
    echo "${HOME}/public/MarlinWorkdirs/ZHH" >> $PYTHON_ENV_ROOT/lib/python$PYTHON_VERSION/site-packages/zhh.pth
fi

if [ ! -f $PYTHON_ENV_ROOT/lib/python$PYTHON_VERSION/site-packages/lcio.pth ]; then
    echo "${HOME}/ILCSoft/LCIO/python" >> $PYTHON_ENV_ROOT/lib/python$PYTHON_VERSION/site-packages/lcio.pth
fi

if [ ! -f $PYTHON_ENV_ROOT/lib/python$PYTHON_VERSION/site-packages/pyhepcommon.pth ]; then
    echo "${HOME}/public/MarlinWorkdirs/pyhepcommon" >> $PYTHON_ENV_ROOT/lib/python$PYTHON_VERSION/site-packages/pyhepcommon.pth
fi
