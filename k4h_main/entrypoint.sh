#!/bin/bash

# kill $(ps -ef | grep '[a]utomount' | awk '{print $2}')
# Load cvmfs

# Source env file
. /root/.env

echo "Configuring cvmfs"
if [[ $(uname -r) =~ WSL2$ ]]; then
    cvmfs_config wsl2_start
    sleep 2
else
    # exec /usr/sbin/init &
    # sleep 3

    cvmfs_config setup
    service autofs restart
fi

for repo in ilc.desy.de sw.hsf.org sft.cern.ch
do
    if [[ ! -d "/cvmfs/$repo" ]]; then
        echo "Attempting to mount repo <$repo>"
        
        #mkdir -p /cvmfs/$repo
        mount -t cvmfs $repo /cvmfs/$repo
    else
        echo "Repo <$repo> already mounted"
    fi
done

cvmfs_config probe

if [[ ! -f /.init ]]; then

    if [[ "true" == "false" ]]; then
        # Source key4hep stack
        source /cvmfs/ilc.desy.de/key4hep/setup.sh -r $K4H_RELEASE

        # Populate most important tools inside cvmfs cache
        # See https://gitlab.desy.de/ftx-sft-key4hep/tutorials/-/blob/main/key4hep_installation.md#some-commands-to-populate-parts-of-the-cvmfs-cache
        gcc --version
        root-config --version
        cmake --version
        python --version
        Marlin -h
        ddsim -h
        ls $lcgeo_DIR
    fi

    # Clone main repository
    mkdir -p ~/public/DevRepositories
    mkdir -p ~/public/ILCSoft/
    mkdir -p ~/public/MarlinWorkdirs/

    cd ~/public/ILCSoft
    git clone https://github.com/iLCSoft/LCIO.git
    git clone https://github.com/iLCSoft/ILDConfig.git
    git clone https://github.com/iLCSoft/MarlinReco.git
    git clone git@gitlab.desy.de:bryan.bliewert/Physsim.git

    # Setup ZHH
    cd ~/public/MarlinWorkdirs
    git clone --recurse-submodules https://github.com/nVentis/ZHH.git

    # Store result
    touch /.init

    echo "Setup complete"
fi

# run the command given as arguments from CMD
exec "$@"