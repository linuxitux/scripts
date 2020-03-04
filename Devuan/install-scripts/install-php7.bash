#!/bin/bash

PHP_VERSION="7.1.7"
tar -axf php-${PHP_VERSION}.tar.gz \
&& chown -R root:root php-${PHP_VERSION}/ \
&& cd php-${PHP_VERSION}/ \
|| exit 1

export CFLAGS="-O3 -march=native -mtune=native"
export CXXFLAGS=${CFLAGS}

INSTALLDIR="/usr/local/php7"

./configure --prefix=/usr/local/php7/ \
--disable-cli \
--enable-fpm \
--with-fpm-user=www-data \
--with-fpm-group=www-data \
--disable-ipv6 \
--with-openssl \
--with-pcre-regex \
--with-pcre-jit \
--with-zlib \
--enable-bcmath \
--with-bz2 \
--with-curl \
--enable-calendar \
--enable-exif \
--enable-ftp \
--with-gd \
--enable-gd-native-ttf \
--with-gettext \
--with-mhash \
--enable-intl \
--enable-mbstring \
--with-mcrypt \
--with-mysqli \
--enable-pcntl \
--with-pdo-mysql \
--with-readline \
--enable-sockets \
--enable-zip \
|| exit 1

make -j4 \
&& make install \
&& make clean \
&& echo -e "\n'$(basename $(pwd))' installed OK.\n" \
&& cd ..
