FROM clamav/clamav:stable

USER root

# initial install of packages
RUN apk update && \
    apk add ruby && \
    apk add ca-certificates && \
    apk add ca-certificates && \
    gem install faraday -v >= 1.9.3 && \
    gem install sentry-raven && \
    gem install rufus-scheduler

# permission juggling
RUN chown clamav:clamav /var/lib/clamav/*.cvd
RUN mkdir /var/run/clamav && \
    chown clamav:clamav /var/run/clamav && \
    chmod 750 /var/run/clamav

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
CMD ["sh bootstrap.sh"]
