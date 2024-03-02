# INTENDED TO RUN AFTER SETUP OF PRIVATE SSH KEY

git config --global user.email "bryan.bliewert@nventis.eu"
git config --global user.name "Bryan Bliewert"

chmod 0700 ~/.ssh
chmod 600 $HOME/.ssh/id_rsa
ssh-add ~/.ssh/id_rsa

eval "$(ssh-agent -s)"

mkdir -p /nfs/

mkdir -p /root/public
ln -s /root/DevRepositories /root/public/MarlinWorkdirs

mkdir -p /afs/desy.de/user/b
ln -s /root /afs/desy.de/user/b/bliewert


# LCIO
conda activate graphjet_pyg
echo "Setting up LCIO"

cmake -DBUILD_ROOTDICT=ON -D CMAKE_CXX_STANDARD=17 ..
make -j 4 install
conda deactivate

# BUILD DEPENDENCIES FOR PACKAGES REQUIRING KEY4HEP STAACK

source /cvmfs/ilc.desy.de/key4hep/setup.sh

# Physsim
cd $HOME/ILCSoft
git clone https://gitlab.desy.de/bryan.bliewert/Physsim.git

mkdir -p cd $HOME/ILCSoft/Physsim/build
cd $HOME/ILCSoft/Physsim/build
cmake ..

# for building Physsim, marlin has to be in CPATH (additional to those added by the key4hep stack)
export CPATH=/cvmfs/ilc.desy.de/key4hep/releases/089d775cf2/marlin/1.19/x86_64-centos7-gcc12.3.0-opt/d6jkp/include:$CPATH
export CPATH=/cvmfs/ilc.desy.de/key4hep/releases/2023-05-23/ilcutil/1.7/x86_64-centos7-gcc12.3.0-opt/b3vqf/include:$CPATH
export CPATH=/cvmfs/ilc.desy.de/key4hep/releases/2023-05-23/root/6.28.04/x86_64-centos7-gcc12.3.0-opt/owni5/include:$CPATH

# Install other depenencies
cd $HOME/DevRepositories
git clone https://gitlab.desy.de/bryan.bliewert/graphjet.git
git clone https://github.com/nVentis/ZHH.git

# ZHH