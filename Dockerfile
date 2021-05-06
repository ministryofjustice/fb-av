FROM debian:buster-slim

# Debian Base to use
ENV DEBIAN_VERSION buster

# initial install of av daemon
RUN echo "deb http://http.debian.net/debian/ $DEBIAN_VERSION main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://http.debian.net/debian/ $DEBIAN_VERSION-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/ $DEBIAN_VERSION/updates main contrib non-free" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install ruby-full -y && \
    gem install sentry-raven && \
    gem install rufus-scheduler && \
    apt-get install -y ca-certificates && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -qq \
        clamav \
        clamav-daemon \
        clamav-freshclam \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=754256621582.dkr.ecr.eu-west-2.amazonaws.com/formbuilder/fb-av:base /var/lib/clamav/main.cvd /var/lib/clamav/main.cvd
COPY --from=754256621582.dkr.ecr.eu-west-2.amazonaws.com/formbuilder/fb-av:base /var/lib/clamav/daily.cvd /var/lib/clamav/daily.cvd
COPY --from=754256621582.dkr.ecr.eu-west-2.amazonaws.com/formbuilder/fb-av:base /var/lib/clamav/bytecode.cvd /var/lib/clamav/bytecode.cvd

RUN chown clamav:clamav /var/lib/clamav/*.cvd

# permission juggling
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

# volume provision
VOLUME ["/var/lib/clamav"]

# port provision
EXPOSE 3310

USER 101

# av daemon bootstrapping
ADD bootstrap.sh /
CMD ["/bootstrap.sh"]
