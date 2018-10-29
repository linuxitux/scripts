#!/bin/bash

COLLECTD_VERSION="5.8.0"

tar -axf collectd-${COLLECTD_VERSION}.tar.* \
&& chown -R root:root collectd-${COLLECTD_VERSION}/ \
|| exit 1

export CFLAGS="-O3 -march=native -mtune=native"
export CXXFLAGS=${CFLAGS}
export CPPFLAGS=${CFLAGS}

cd collectd-${COLLECTD_VERSION}/
./configure \
  --disable-werror \
  --prefix=/usr/local/collectd \
  \
  --enable-cpu \
  --enable-curl \
  --enable-df \
  --enable-disk \
  --enable-load \
  --enable-memory \
  --enable-network \
  --enable-processes \
  --enable-protocols \
  --enable-swap \
  --enable-syslog \
  --enable-tail \
  --enable-tcpconns \
  --enable-unixsock \
  --enable-uptime \
  --enable-users \
  --enable-vmem \
|| exit 1

# plugins adicionales
#   --enable-apache \
#   --enable-iptables \
#   --enable-mysql \
#   --enable-postgresql \
#   --enable-python \
# ejecutar ./configure --help para ver todos

make \
&& make install \
&& echo -e "\nINSTALACION '$(basename $(pwd))' OK!\n" \
|| exit 1

cp contrib/redhat/init.d-collectd /etc/init.d/collectd \
&& chkconfig collectd on \
&& cd .. \

