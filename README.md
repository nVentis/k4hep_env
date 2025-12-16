# k4hep_env

This docker compose file sets up a local container running alma9 and cvmfs with ilc.desy.de and sw.hsf.org enabled. Tested on Ubuntu 24 and WSL2. 

# Running

Execute the following command to build and run the container: `docker compose --profile auto-<cpu/gpu> -e=PRELOAD_CVMFS=<true/false> up`. Choose `auto-gpu` if you want to passthrough a local NVIDIA gpu, `auto-cpu` otherwise. The environment variable option `PRELOAD_CVMFS` will default to `false` if not supplied (see .env). 

You can also add your public SSH key to the environment variable `SSH_PUBLIC_KEY` to have OpenSSH set up for you.