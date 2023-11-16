FROM clamav/clamav:stable AS base

USER root

# permission juggling
RUN chown clamav:clamav /var/lib/clamav

RUN mkdir /var/run/clamav /run/lock && \
    chown -R clamav:clamav /var/run/clamav /run/lock /var/lock && \
    chmod -R 750 /var/run/clamav /run/lock /var/lock

RUN echo "TCPSocket 3310" >> /etc/clamav/clamd.conf && \
    echo "LogClean yes" >> /etc/clamav/clamd.conf

ADD clamd.sh /

# volume provision
VOLUME ["/var/lib/clamav"]

# port provision
EXPOSE 3310

USER 100
