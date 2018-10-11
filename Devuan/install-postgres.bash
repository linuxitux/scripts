#!/bin/bash

PGSQL_VERSION="9.6.3"
tar -axf postgresql-${PGSQL_VERSION}.tar.bz2 \
&& chown -R root:root postgresql-${PGSQL_VERSION}/ \
&& cd postgresql-${PGSQL_VERSION}/ \
|| exit 1

export CFLAGS="-O3 -march=native -mtune=native"
export CXXFLAGS=${CFLAGS}

#export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/libressl/lib"
#export LDFLAGS="${LDFLAGS} -s -L/usr/local/libressl/lib -Wl,-rpath=/usr/local/libressl/lib"
export LIBS="${LIBS} -lcrypto -lssl -lresolv -lrt"
#export CPPFLAGS="${CPPFLAGS} -I/usr/local/libressl/include"

INSTALLDIR="/usr/local/pgsql"

make dist clean

./configure \
   --prefix=${INSTALLDIR} \
   --with-openssl \
   --with-ossp-uuid \
|| exit 1

make -j4 \
&& make install \
&& cd contrib/dblink/ \
&& make \
&& cp dblink.so ${INSTALLDIR}/lib \
&& cp dblink--*.sql dblink.control ${INSTALLDIR}/share/extension \
&& cd ../../ \
&& cd contrib/pgcrypto/ \
&& make \
&& cp pgcrypto.so ${INSTALLDIR}/lib \
&& cp pgcrypto--*.sql pgcrypto.control ${INSTALLDIR}/share/extension \
&& cd ../../ \
&& cd contrib/uuid-ossp/ \
&& make \
&& cp uuid-ossp.so ${INSTALLDIR}/lib \
&& cp uuid-ossp*.sql uuid-ossp.control ${INSTALLDIR}/share/extension \
&& cd ../../ \
&& make clean \
&& echo -e "\n'$(basename $(pwd))' installed OK.\n" \
&& cd ..

groupadd postgres
useradd -g postgres -m -s /bin/bash postgres
chgrp -R postgres ${INSTALLDIR}/share/extension
chmod o+rx ${INSTALLDIR}
