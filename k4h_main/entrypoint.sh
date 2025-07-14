#!/bin/bash

# Source env file
. /root/.env

source /data/entrypoint_run.sh

if [[ ! -f /.init ]]; then
    if [[ "$PRELOAD_CVMFS" == "true" ]]; then
        source /data/entrypoint_setup.sh
    fi

    # Load environment variables in every (login) shell
    echo ". /root/.env" >> ~/.bashrc

    touch /.init

    echo "Setup complete"
fi

# run the command given as arguments from CMD
exec "$@"