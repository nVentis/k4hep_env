# k4hep_env

This docker compose file sets up a local container running alma9 and cvmfs with ilc.desy.de and sw.hsf.org enabled. Tested on Ubuntu 24 and WSL2. 

# Setup

1. Adjust the `.env` file and fill in your own `SSH_PUBLIC_KEY`
2. `docker compose --profile auto-<cpu/gpu> up`. Choose `auto-gpu` if you want to passthrough a local NVIDIA gpu, `auto-cpu` otherwise.  
3. Profit

