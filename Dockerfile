FROM clamav/clamav:stable

USER root

# initial install of packages
RUN apk update && \
    apk add bash && \
    apk add ruby && \
    apk add ca-certificates && \
    gem install faraday -v >= 1.9.3 && \
    gem install sentry-raven && \
    gem install rufus-scheduler

# permission juggling
RUN chown clamav:clamav /var/lib/clamav/*.cvd

RUN mkdir /var/run/clamav /run/lock && \
    chown -R clamav:clamav /var/run/clamav /run/lock /var/lock && \
    chmod -R 750 /var/run/clamav /run/lock /var/lock

# av configuration update
RUN sed -i 's/^Foreground .*$/Foreground true/g' /etc/clamav/clamd.conf && \
    echo "TCPSocket 3310" >> /etc/clamav/clamd.conf && \
    sed -i 's/^Foreground .*$/Foreground true/g' /etc/clamav/freshclam.conf && \
    echo "SafeBrowsing no" >> /etc/clamav/freshclam.conf

# monitor clamav updates
ADD scripts/clamav_check.rb /
# add the probe script
ADD readiness_probe.sh /

# volume provision
VOLUME ["/var/lib/clamav"]

# port provision
EXPOSE 3310

# av daemon bootstrapping
ADD bootstrap.sh /
CMD ["bash bootstrap.sh"]

USER 100