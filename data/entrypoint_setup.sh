#!/bin/bash

# Source key4hep stack
source /cvmfs/sw.hsf.org/key4hep/setup.sh -r $K4H_RELEASE

# Populate most important tools inside cvmfs cache
# See https://gitlab.desy.de/ftx-sft-key4hep/tutorials/-/blob/main/key4hep_installation.md#some-commands-to-populate-parts-of-the-cvmfs-cache
gcc --version
root-config --version
cmake --version
python --version
Marlin -h
ddsim -h
ls $lcgeo_DIR

# Clone main repository
mkdir -p ~/public/DevRepositories
mkdir -p ~/public/MarlinWorkdirs/

# Setup ZHH
#cd ~/public/MarlinWorkdirs
#git clone --recurse-submodules https://github.com/nVentis/ZHH.git