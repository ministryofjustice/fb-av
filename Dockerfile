FROM clamav/clamav:stable AS base

USER root

RUN echo "LogClean yes" >> /etc/clamav/clamd.conf \
    && mkdir -p /var/run/clamav /var/lock /run/lock \
    && chown -R clamav:clamav /var/run/clamav /var/lock /run/lock \
    && chmod -R 750 /var/run/clamav /var/lock /run/lock

# permission juggling
RUN chown clamav:clamav /var/lib/clamav

# volume provision
VOLUME ["/var/lib/clamav"]

# port provision
EXPOSE 3310

USER 1000
