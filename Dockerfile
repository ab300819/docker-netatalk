FROM debian:stretch
ENV NETATALK_VERSION 3.1.12

ENV DEPS="build-essential \
        libevent-dev \
        libssl-dev \
        libgcrypt-dev \
        libkrb5-dev \
        libpam0g-dev \
        libwrap0-dev \
        libdb-dev \
        libtdb-dev \
        libmariadbclient-dev \
        avahi-daemon \
        libavahi-client-dev \
        libacl1-dev \
        libldap2-dev \
        libcrack2-dev \
        systemtap-sdt-dev \
        libdbus-1-dev \
        libdbus-glib-1-dev \
        libglib2.0-dev \
        libio-socket-inet6-perl \
        tracker \
        libtracker-sparql-1.0-dev \
        libtracker-miner-1.0-dev"

ENV DEBIAN_FRONTEND=noninteractive

COPY sources.list /etc/apt/sources.list

WORKDIR /home

RUN apt-get update && \
    apt-get install \
            --no-install-recommends \
            --fix-missing \
            --assume-yes \
            $DEPS \
            avahi-daemon \
            axel \
            vim && \
    axel "http://ufpr.dl.sourceforge.net/project/netatalk/netatalk/${NETATALK_VERSION}/netatalk-${NETATALK_VERSION}.tar.bz2" && \
    tar xvf "netatalk-${NETATALK_VERSION}.tar.bz2"

WORKDIR /home/netatalk-${NETATALK_VERSION}

RUN ./configure \
        --with-init-style=debian-systemd \
        --sysconfdir=/etc \
        --without-libevent \
        --without-tdb \
        --with-cracklib \
        --enable-krbV-uam \
        --with-pam-confdir=/etc/pam.d \
        --with-dbus-daemon=/usr/bin/dbus-daemon \
        --with-dbus-sysconf-dir=/etc/dbus-1/system.d \
        --with-tracker-pkgconfig-version=1.0 && \
    make && \
    make install && \
    apt-get install --yes \
        libavahi-client3 \
        libevent-2.1-6 \
        libevent-core-2.1-6 \
        libwrap0 \
        libtdb1 \
        default-mysql-client \
        libcrack2 \
        libdbus-glib-1-2 \
        libssl1.1 && \
    apt-get --quiet --yes autoremove && \
    apt-get --quiet --yes autoclean && \
    apt-get --quiet --yes clean && \
    rm -rf /home/netatalk* && \
    mkdir /media/share && \
    mkdir /media/timemachine

COPY docker-entrypoint.sh /home/docker-entrypoint.sh
COPY afp.conf /etc/afp.conf
ENV DEBIAN_FRONTEND=newt

CMD ["/home/docker-entrypoint.sh"]
