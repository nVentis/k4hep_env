#!/bin/bash

echo "Configuring cvmfs"

if [[ ! -f /.init ]]; then
    echo "CVMFS_REPOSITORIES=ilc.desy.de,sw.hsf.org,sft.cern.ch" >> /etc/cvmfs/default.local
    echo "CVMFS_HTTP_PROXY=DIRECT" >> /etc/cvmfs/default.local

    mkdir -p /etc/cvmfs/keys/hsf.org
    cp -R /cvmfs/cvmfs-config.cern.ch/etc/cvmfs/keys/hsf.org/** /etc/cvmfs/keys/hsf.org

    # For setting up ilc.desy.de
    if [[ ! -f "/etc/cvmfs/keys/desy.de/desy.de.pub" ]]; then
        mkdir -p /etc/cvmfs/keys/desy.de/

        # See https://confluence.desy.de/display/grid/DESY-CVMFS-Repositories_174022946.html
        wget https://confluence.desy.de/display/grid/attachments/174022946/174022956.pub -O /etc/cvmfs/keys/desy.de/desy.de.pub
    fi

    if [[ ! -f "/etc/cvmfs/domain.d/desy.de.conf" ]]; then
        mkdir -p /etc/cvmfs/domain.d/

        # See https://confluence.desy.de/display/grid/CVMFS-repositories_159747860.html
        cat >> /etc/cvmfs/domain.d/desy.de.conf <<EOF
CVMFS_SERVER_URL="http://grid-cvmfs-one.desy.de:8000/cvmfs/@fqrn@"
CVMFS_KEYS_DIR=/etc/cvmfs/keys/desy.de
CVMFS_USE_GEOAPI=yes
EOF
    fi
fi

# ilc.desy.de 
for try in 1 2 3
do
    echo "Try $try to mount CVMFS"
    cvmfs_config setup

    if [[ $(uname -r) =~ WSL2$ ]]; then
        echo "Starting CVMFS WSL2 shim"
        cvmfs_config wsl2_start
        
    else
        # exec /usr/sbin/init &
        # sleep 3

        service autofs restart
    fi

    sleep 2

    failed=0

    for repo in sw.hsf.org sft.cern.ch ilc.desy.de
    do
        echo "Trying to mount repo <$repo>"

        if [[ ! -d "/cvmfs/$repo" || -z "$( ls -A "/cvmfs/$repo" )" ]]; then
            failed=1

            mkdir -p /cvmfs/$repo
            mount -t cvmfs $repo /cvmfs/$repo

            echo "Mounted repo <$repo>"
        else
            echo "Repo <$repo> already mounted"
        fi
    done

    if [[ $failed -eq 0 ]]; then
        echo "CVMFS mounted successfully"
        break
    fi

    sleep 2
done

cvmfs_config probe