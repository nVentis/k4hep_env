# Build base images
FROM ilcsoft/tutorial:aidacs7 as base

COPY k4h_main/entrypoint.sh /entrypoint.sh
COPY k4h_main/setup.sh /setup.sh
#ENV DEBIAN_FRONTEND=noninteractive

RUN chmod a+x /entrypoint.sh
RUN chmod a+x /setup.sh

# Build dev image
FROM base as dev
ENV APP_ENV=dev

RUN /setup.sh

ENTRYPOINT ["/entrypoint.sh"]
#CMD ["tail", "-f", "/dev/null"]
CMD ["/usr/sbin/sshd", "-D"]

# Build prod image
FROM base as prod
ENV APP_ENV=prod

RUN /setup.sh

ENTRYPOINT ["/entrypoint.sh"]
#CMD ["tail", "-f", "/dev/null"]
CMD ["/usr/sbin/sshd", "-D"]