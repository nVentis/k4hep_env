#!/bin/bash

exec /usr/sbin/init &

if [ ! -f /.init ] ; then
    # Setup SSH
    echo "Setting up SSH"
    touch $HOME/.ssh/authorized_keys
    cat >> $HOME/.ssh/authorized_keys <<EOF
$SSH_PUBLIC_KEY

EOF

    chmod 700 $HOME/.ssh
    chmod 600 $HOME/.ssh/authorized_keys

    # Setup cvmfs
    echo "Configuring cvmfs"
    if [[ $(uname -r) =~ WSL2$ ]]; then
        echo "Using WSL2 shim"
        sudo cvmfs_config wsl2_start
    else
        echo "Not running in WSL2. Using default setup."
        sudo cvmfs_config setup
        sudo service autofs restart
    fi
    
    cvmfs_config probe

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

    # Setup ILCSoft
    cd ~
    mkdir ILCSoft
    cd ILCSoft

    git clone https://github.com/iLCSoft/LCIO.git

    # Store result
    touch /.init
fi

# run the command given as arguments from CMD
exec "$@"