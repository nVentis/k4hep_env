#FROM ilcsoft/tutorial:aidacs7 as base
FROM ghcr.io/key4hep/key4hep-images/alma9-cvmfs:latest as base

COPY k4h_main/entrypoint.sh /entrypoint.sh
COPY k4h_main/setup.sh /setup.sh
COPY .env /root/.env

RUN chmod a+x /entrypoint.sh
RUN chmod a+x /setup.sh
#ENV DEBIAN_FRONTEND=noninteractive
RUN mkdir -p /data
COPY data/entrypoint_run.sh /data/entrypoint_run.sh
COPY data/entrypoint_setup.sh /data/entrypoint_setup.sh
RUN chmod a+x /data/entrypoint_run.sh
RUN chmod a+x /data/entrypoint_setup.sh

RUN yum -y update && yum -y install openssh-server wget nano tree pv htop
RUN dnf -y install autofs

# Build dev image
FROM base as dev
ENV APP_ENV=dev

#RUN /setup.sh
RUN touch /.init
RUN echo "echo Test" > /data/entrypoint_run.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
#CMD ["/usr/sbin/sshd", "-D", "-e"]

# Build prod image
FROM base as prod
ENV APP_ENV=prod

#RUN /setup.sh
RUN touch /.init
RUN echo "echo Test" > /data/entrypoint_run.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
#CMD ["/usr/sbin/sshd", "-D", "-e"]