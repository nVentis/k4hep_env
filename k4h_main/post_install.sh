# INTENDED TO RUN AFTER SETUP OF PRIVATE SSH KEY

git config --global user.email "bryan.bliewert@nventis.eu"
git config --global user.name "Bryan Bliewert"

chmod 0700 ~/.ssh
chmod 600 $HOME/.ssh/id_rsa
eval "$(ssh-agent -s)"

ssh-add ~/.ssh/id_rsa

mkdir -p /nfs/

mkdir -p /root/public
ln -s /root/DevRepositories /root/public/MarlinWorkdirs

mkdir -p /afs/desy.de/user/b
ln -s /root /afs/desy.de/user/b/bliewert

# Link conda environment + Fix permissions
mkdir -p /nfs/dust/ilc/user/bliewert/.mambaforge/envs
ln -s ~/miniforge3/envs/graphjet_pyg /nfs/dust/ilc/user/bliewert/.mambaforge/envs/graphjet_pyg

chmod -R 777 /afs/desy.de/user/b/bliewert/public/MarlinWorkdirs/graphjet

# LCIO
conda activate graphjet_pyg
echo "Setting up LCIO"

mkdir -p $HOME/ILCSoft/LCIO/build
cd $HOME/ILCSoft/LCIO/build

cmake -DBUILD_ROOTDICT=ON -DCMAKE_CXX_STANDARD=17 ..
make -j 4 install

# Link sucht that LCIO is available in the python environment
ln -s /root/ILCSoft/LCIO/build/_deps/sio_extern-src/python $HOME/ILCSoft/LCIO/python
conda env config vars set LD_LIBRARY_PATH=$HOME/ILCSoft/LCIO/build/lib64

cd ..
source ./setup.sh

conda deactivate

# BUILD DEPENDENCIES FOR PACKAGES REQUIRING KEY4HEP STAACK

source /cvmfs/ilc.desy.de/key4hep/setup.sh

# ILCSoft: Physsim, ILDConfig
cd $HOME/ILCSoft
git clone git@gitlab.desy.de:bryan.bliewert/Physsim.git
git clone https://github.com/iLCSoft/ILDConfig.git

mkdir -p cd $HOME/ILCSoft/Physsim/build
cd $HOME/ILCSoft/Physsim/build
cmake ..

# Link Physsim for compatability
ln -s $HOME/ILCSoft/Physsim/lib64 $HOME/ILCSoft/Physsim/lib

# Link ILCSoft for compatability
ln -s $HOME/ILCSoft /afs/desy.de/user/b/bliewert/public/ILCSoft

# for building Physsim, marlin has to be in CPATH (additional to those added by the key4hep stack)
export CPATH=/cvmfs/ilc.desy.de/key4hep/releases/089d775cf2/marlin/1.19/x86_64-centos7-gcc12.3.0-opt/d6jkp/include:$CPATH
export CPATH=/cvmfs/ilc.desy.de/key4hep/releases/2023-05-23/ilcutil/1.7/x86_64-centos7-gcc12.3.0-opt/b3vqf/include:$CPATH
export CPATH=/cvmfs/ilc.desy.de/key4hep/releases/2023-05-23/root/6.28.04/x86_64-centos7-gcc12.3.0-opt/owni5/include:$CPATH

make
make install

# Install other depenencies
cd $HOME/DevRepositories
git clone git@gitlab.desy.de:bryan.bliewert/graphjet.git
git clone https://github.com/nVentis/ZHH.git

# ZHH

# Add to envirionment
# See https://stackoverflow.com/questions/37006114/anaconda-permanently-include-external-packages-like-in-pythonpath
cat >> $HOME/miniforge3/envs/graphjet_pyg/lib/python3.11/site-packages/MEM_HEP.pth <<EOF
${HOME}/DevRepositories/MEM_HEP

EOF

cat >> $HOME/miniforge3/envs/graphjet_pyg/lib/python3.11/site-packages/graphjet.pth <<EOF
${HOME}/DevRepositories/graphjet

EOF

cat >> $HOME/miniforge3/envs/graphjet_pyg/lib/python3.11/site-packages/lcio.pth <<EOF
${HOME}/ILCSoft/LCIO/python

EOF

# MarlinReco (e.g. SLDCorrection)
cd $HOME/DevRepositories
git clone https://github.com/iLCSoft/MarlinReco.git

mkdir -p /afs/desy.de/user/b/bliewert/public/yradkhorrami
ln -s $HOME/ILCSoft/MarlinReco/Analysis/SLDCorrection /afs/desy.de/user/b/bliewert/public/yradkhorrami/SLDecayCorrection

# Build ZHH
cd $HOME/DevRepositories/ZHH
source compile_from_scratch.sh

# MEM_HEP dependencies (pytorch_scatter+sparse, pybind11 for JetConvProcessor)
mkdir $HOME/DevLocal
ln -s $HOME/DevLocal /afs/desy.de/user/b/bliewert/public/DevLocal

cd $HOME/DevLocal

git clone https://github.com/rusty1s/pytorch_scatter.git
git clone https://github.com/rusty1s/pytorch_sparse.git
git clone https://github.com/pybind/pybind11.git

mkdir -p pytorch_scatter/build
mkdir -p pytorch_sparse/build
mkdir -p pybind11/build

cd $HOME/DevLocal/pytorch_scatter/build
cmake -D CMAKE_INSTALL_PREFIX:PATH=/afs/desy.de/user/b/bliewert/public/DevLocal/pytorch_scatter -DCMAKE_PREFIX_PATH="..." ..
make
make install

cd $HOME/DevLocal/pytorch_sparse
git submodule update --init --recursive
cd build
cmake -D CMAKE_INSTALL_PREFIX:PATH=/afs/desy.de/user/b/bliewert/public/DevLocal/pytorch_scatter -DCMAKE_PREFIX_PATH="..." ..
make
make install

# Pybind11
cd $HOME/DevLocal/pybind11/build
cmake -D CMAKE_INSTALL_PREFIX:PATH=/afs/desy.de/user/b/bliewert/public/DevLocal/pybind11 -DCMAKE_PREFIX_PATH="..." ..
make
make install

# Compile MEM_HEP processors
cd $HOME/DevRepositories/MEM_HEP
source compile_from_scratch.sh

# Link external datasets
mkdir -p /pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged/500-TDR_ws/hh/ILD_l5_o1_v02_nobg
ln -s /nfs/dust/ilc/user/bliewert/ILD_l5_o1_v02_nobg/v02-02-03 /pnfs/desy.de/ilc/prod/ilc/mc-2020/ild/dst-merged/500-TDR_ws/hh/ILD_l5_o1_v02_nobg/v02-02-03

# TODO: Download lcfiplus weight files
# In ZHH analysis, weight 6q500_v04_p00_ildl5_c0_bdt.weights.xml is used (as of 2024.03.03)
cd /afs/desy.de/user/b/bliewert/public/ILCSoft/ILDConfig/LCFIPlusConfig/lcfiweights
tar -xvzf 6q500_v04_p00_ildl5.tar.gz

