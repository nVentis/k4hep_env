#!/bin/bash

# Source env file
. /root/.env

source /data/entrypoint_run.sh

if [[ ! -f /.init ]]; then
    source /data/entrypoint_setup.sh

    touch /.init

    echo "Setup complete"
fi

# run the command given as arguments from CMD
exec "$@"