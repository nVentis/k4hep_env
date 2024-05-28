#!/bin/bash

# kill $(ps -ef | grep '[a]utomount' | awk '{print $2}')
# Load cvmfs

# Source env file
. /root/.env

echo "Configuring cvmfs"
if [[ $(uname -r) =~ WSL2$ ]]; then
    # sudo cvmfs_config wsl2_start
    sudo mkdir -p /cvmfs/ilc.desy.de
    sudo mount -t cvmfs ilc.desy.de /cvmfs/ilc.desy.de

    sudo mkdir -p /cvmfs/sw.hsf.org
    sudo mount -t cvmfs sw.hsf.org /cvmfs/sw.hsf.org

    sudo mkdir -p /cvmfs/sft.cern.ch
    sudo mount -t cvmfs sft.cern.ch /cvmfs/sft.cern.ch
else
    # exec /usr/sbin/init &
    # sleep 3

    sudo cvmfs_config setup
    sudo service autofs restart
fi

cvmfs_config probe

if [ ! -f /.init ] ; then

    if [ "true" == "false" ]; then
        # Source key4hep stack
        source /cvmfs/ilc.desy.de/key4hep/setup.sh

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
        cd ~
        mkdir -p DevRepositories
        cd DevRepositories

        git clone https://github.com/nVentis/MEM_HEP.git
    fi

    # Store result
    touch /.init

    echo "Setup complete"
fi

# run the command given as arguments from CMD
exec "$@"