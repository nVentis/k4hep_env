#!/bin/bash

conda activate py311
pip install ipywidgets

# LCIO
echo "Setting up LCIO"

mkdir -p $HOME/ILCSoft/LCIO/build
cd $HOME/ILCSoft/LCIO/build

cmake -DBUILD_ROOTDICT=ON -DCMAKE_CXX_STANDARD=17 ..
make -j 4 install

# Link such that LCIO is available in the python environment
ln -s /root/ILCSoft/LCIO/build/_deps/sio_extern-src/python $HOME/ILCSoft/LCIO/python
conda env config vars set LD_LIBRARY_PATH=$HOME/ILCSoft/LCIO/build/lib64

cat >> $HOME/miniforge3/envs/py311/lib/python3.11/site-packages/lcio.pth <<EOF
${HOME}/ILCSoft/LCIO/python

EOF

# Link directories
mkdir -p /pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged
ln -s /nfs/dust/ilc/user/bliewert/500-TDR_ws/ /pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged/500-TDR_ws

# bashrc commands
echo "alias sk4h='source /cvmfs/ilc.desy.de/key4hep/key4hep_latest_setup.sh'" >> $HOME/.bashrc