# PHP 7.3 image with php cli, fpm, memcache, maxmind, mongo and blackfire extensions
FROM phusion/baseimage:latest
# FROM php:7.3

# Set the env variable DEBIAN_FRONTEND to noninteractive
ARG DEBIAN_FRONTEND=noninteractive
ARG LC_ALL=C.UTF-8

# Install essential packages
RUN set -e; \
    echo "TZ='Asia/Taipei'; export TZ" >> ~/.profile && \
    add-apt-repository -y  ppa:ondrej/php && \
    add-apt-repository ppa:maxmind/ppa && \
    # curl https://packagecloud.io/gpg.key | apt-key add - && \
    # echo "deb http://packages.blackfire.io/debian any main" | tee /etc/apt/sources.list.d/blackfire.list && \
    apt-get update && apt-get install -y --allow-unauthenticated --no-install-recommends \
    curl \
    git \
    locales \
    ca-certificates \
    curl \
    zip \
    memcached \
    php-pear \
    # install libmaxminddb
    libmaxminddb0 libmaxminddb-dev mmdb-bin \
    # # install PHP
    php-memcached \
    php-redis \
    php7.3 \
    php7.3-common php7.3-json php7.3-opcache php7.3-readline \
    php7.3-cli \
    php7.3-curl \
    php7.3-dev \
    php7.3-fpm \
    php7.3-gd \
    php7.3-gmp \
    php7.3-intl \
    php7.3-json \
    php7.3-mbstring \
    php7.3-oauth \
    php7.3-opcache \
    php7.3-soap \
    php7.3-xml \
    php7.3-zip \
    php7.3-yaml \
    php7.3-mysql \
    nginx \
    # blackfire-agent blackfire-php \
    # mongodb extension requirement
    pkg-config libssl-dev \
    jq && \
    # Install MongoDB
    pecl channel-update pecl.php.net && pecl install channel://pecl.php.net/geospatial-0.2.0 && pecl install mongodb && echo "extension=mongodb.so" > /etc/php/7.3/mods-available/mongodb.ini && \
    phpenmod -v 7.3 mongodb zip memcache xdebug && \
    # Install Maxmind
    # mkdir -p /usr/local/share/maxmind && \
    # curl -s -L -C - "http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz" -o /usr/local/share/maxmind/GeoLite2-City.mmdb.gz && \
    # gunzip /usr/local/share/maxmind/GeoLite2-City.mmdb.gz && \
    # useradd nginx && mkdir -p /var/lib/php/session && chgrp nginx /var/lib/php/session && \
    # xdebug log dir
    # test ! -e /var/log/xdebug && mkdir /var/log/xdebug && chown nginx:nginx /var/log/xdebug && \
    curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin  && \
    composer global require hirak/prestissimo && \
    # Set locales
    locale-gen en_US && \
    # Set up CA root certificates
    mkdir -p /etc/ssl/certs/ && update-ca-certificates --fresh

# node js
RUN apt-get install -y apt-transport-https ca-certificates && \
  curl --fail -ssL -o setup-nodejs https://deb.nodesource.com/setup_6.x && \
  bash setup-nodejs && \
  apt-get install -y nodejs && \
  apt-get install -y build-essential && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -vp /var/run/sshd

# node
# RUN ln -s /usr/bin/nodejs /usr/bin/node

# composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=1.9.0

# install RVM, Ruby, and Bundler
RUN apt install build-essential curl nodejs
RUN gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN \curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.6"
RUN /bin/bash -l -c "rvm use 2.6 --default"

# sass / compass
# RUN gem install sass
# RUN gem install compass
RUN /bin/bash -l -c "gem install --no-document sass -v 3.4.22"
RUN /bin/bash -l -c "gem install --no-document compass"

# gulp, bower
RUN npm install -g gulp
RUN npm install -g bower

# Clean
RUN apt-get purge -y --auto-remove && apt-get clean all && rm -rf /var/lib/apt/ && /etc/init.d/memcached start && php -v

CMD /sbin/my_init