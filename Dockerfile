#FROM ilcsoft/tutorial:aidacs7 as base
FROM ghcr.io/key4hep/key4hep-images/alma9-cvmfs:latest AS base

#RUN yum -y update && yum -y install openssh-server wget nano tree pv htop
#RUN dnf -y install autofs

#COPY k4h_main/entrypoint.sh /entrypoint.sh
#COPY k4h_main/ /root/
#COPY .env /root/.env

RUN echo "Building with $(nproc) cores..."
RUN git clone https://github.com/ILDAnaSoft/ZHH.git ZHH
RUN cd ZHH && bash install.sh --auto

ENTRYPOINT ["/mount.sh"]
CMD ["/bin/bash"]