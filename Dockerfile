FROM clamav/clamav-debian:stable AS base

USER root

# permission juggling
RUN mkdir -p /var/run/clamav /run/lock && \
    chown -R clamav:clamav /var/run/clamav /run/lock /var/lib/clamav /var/lock /var/log && \
    chmod -R 750 /var/run/clamav /run/lock /var/lib/clamav /var/lock  /var/log

RUN echo "LogClean yes" >> /etc/clamav/clamd.conf

# volume provision
VOLUME ["/var/lib/clamav"]

# port provision
EXPOSE 3310

USER 100

# start clamd and freshclam as a non-root user
ENTRYPOINT ["/init-unprivileged"]
