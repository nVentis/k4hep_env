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


# LCIO
conda activate graphjet_pyg
echo "Setting up LCIO"

mkdir -p $HOME/ILCSoft/LCIO/build
cd $HOME/ILCSoft/LCIO/build

cmake -DBUILD_ROOTDICT=ON ..
make -j 4 install

# Link sucht that LCIO is available in the python environment
ln -s /root/ILCSoft/LCIO/build/_deps/sio_extern-src/python $HOME/ILCSoft/LCIO/python
conda env config vars set LD_LIBRARY_PATH=$HOME/ILCSoft/LCIO/build/lib64

cd ..
source ./setup.sh

conda deactivate

# BUILD DEPENDENCIES FOR PACKAGES REQUIRING KEY4HEP STAACK

source /cvmfs/ilc.desy.de/key4hep/setup.sh

# Physsim
cd $HOME/ILCSoft
git clone git@gitlab.desy.de:bryan.bliewert/Physsim.git

mkdir -p cd $HOME/ILCSoft/Physsim/build
cd $HOME/ILCSoft/Physsim/build
cmake ..

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

# WSL2
# External datasets
mkdir -p /nfs/dust/ilc/user/bliewert