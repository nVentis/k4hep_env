#FROM ilcsoft/tutorial:aidacs7 as base
FROM ghcr.io/key4hep/key4hep-images/alma9-cvmfs:latest AS base

#RUN yum -y update && yum -y install openssh-server wget nano tree pv htop
#RUN dnf -y install autofs

#COPY k4h_main/entrypoint.sh /entrypoint.sh
#COPY k4h_main/ /root/
#COPY .env /root/.env

RUN echo "Mounting CVMFS" \
    bash /mount.sh \
    echo "Checking key4hep whether exists..." \
    [ -d /cvmfs/sw.hsf.org/key4hep ] && echo "key4hep found. Cloning ZHH repo..." || exit 1 \
    cd $GITHUB_WORKSPAC && git clone https://github.com/ILDAnaSoft/ZHH.git ZHH
RUN ZHH && echo "Building image with $(nproc) cores..." && bash install.sh --auto

ENTRYPOINT ["/mount.sh"]
CMD ["/bin/bash"]