#!/bin/bash

for f in $(find /cvmfs/ilc.desy.de/key4hep/releases/2023-05-23 -type f -name '*'); do
    md5sum $f > /dev/null
done