#!/bin/bash

OPENLDAP_VERSION="2.4.50"
tar -axf openldap-${OPENLDAP_VERSION}.tgz \
&& chown -R root:root openldap-${OPENLDAP_VERSION}/ \
&& cd openldap-${OPENLDAP_VERSION}/ \
|| exit 1

export CFLAGS="-O3 -march=native -mtune=native"
export CXXFLAGS=${CFLAGS}

INSTALLDIR="/usr/local"
#INSTALLDIR="/usr/local/openldap-${OPENLDAP_VERSION}"

make dist clean

./configure \
  --prefix=${INSTALLDIR} \
  --enable-crypt \
  --enable-modules \
  --enable-rlookups \
  --with-tls=openssl \
  --enable-mdb \
  --disable-bdb \
  --disable-dnssrv \
  --disable-hdb \
  --disable-ldap \
  --disable-meta \
  --disable-monitor \
  --disable-ndb \
  --disable-null \
  --disable-passwd \
  --disable-perl \
  --disable-relay \
  --disable-shell \
  --disable-sock \
  --disable-sql \
  --disable-ipv6 \
  --enable-ppolicy=yes \
  --enable-auditlog=yes \
|| exit 1

make -j4 depend \
&& make -j4 \
&& make install \
&& echo -e "\n'$(basename $(pwd))' installed OK.\n" \
&& cd ..

groupadd ldap
useradd -g ldap -m -s /bin/bash ldap
chgrp -R ldap ${INSTALLDIR}
chmod o+rx ${INSTALLDIR}

