FROM debian:buster
ENV NETATALK_VERSION 3.1.12

ENV DEPS="build-essential libevent-dev libssl-dev libgcrypt-dev libkrb5-dev libpam0g-dev libwrap0-dev libdb-dev libtdb-dev default-libmysqlclient-dev avahi-daemon libavahi-client-dev libacl1-dev libldap2-dev libcrack2-dev systemtap-sdt-dev libdbus-1-dev libdbus-glib-1-dev libglib2.0-dev libio-socket-inet6-perl tracker libtracker-sparql-2.0-dev libtracker-miner-2.0-dev file"
ENV DEBIAN_FRONTEND=noninteractive

COPY sources.list /etc/apt/sources.list

RUN apt-get update \
 && apt-get install \
        --no-install-recommends \
        --fix-missing \
        --assume-yes \
        $DEPS \
        tracker \
        avahi-daemon \
        vim \
        curl wget \
        &&  wget      "http://ufpr.dl.sourceforge.net/project/netatalk/netatalk/${NETATALK_VERSION}/netatalk-${NETATALK_VERSION}.tar.gz" \
        &&  curl -SL  "http://ufpr.dl.sourceforge.net/project/netatalk/netatalk/${NETATALK_VERSION}/netatalk-${NETATALK_VERSION}.tar.gz" | tar xvz

WORKDIR netatalk-${NETATALK_VERSION}

RUN ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --with-init-style=debian-systemd \
        --without-libevent \
        --without-tdb \
        --with-cracklib \
        --enable-krbV-uam \
        --with-pam-confdir=/etc/pam.d \
        --with-dbus-sysconf-dir=/etc/dbus-1/system.d \
        --with-tracker-pkgconfig-version=2.0 \
        &&  make \
            &&  make install \
                &&  apt-get --quiet --yes purge --auto-remove \
        $DEPS \
        tracker-gui \
        libgl1-mesa-dri \
        &&  DEBIAN_FRONTEND=noninteractive apt-get install --yes \
        libavahi-client3 \
        libevent-2.1-6 \
        libevent-core-2.1-6 \
        libwrap0 \
        libtdb1 \
        default-mysql-client \
        libcrack2 \
        libdbus-glib-1-2 \
        libssl1.1 \
        &&  apt-get --quiet --yes autoclean \
         &&  apt-get --quiet --yes autoremove \
          &&  apt-get --quiet --yes clean \
           &&  rm -rf /netatalk* \
            &&  mkdir /media/share \
                && mdir /media/timemachine

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY afp.conf /etc/afp.conf
ENV DEBIAN_FRONTEND=newt

CMD ["/docker-entrypoint.sh"]
