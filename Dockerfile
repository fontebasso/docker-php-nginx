ARG NAME_IMAGE_BASE='php'
ARG NAME_IMAGE_TAG='8.3-fpm-alpine3.20'

FROM ${NAME_IMAGE_BASE}:${NAME_IMAGE_TAG}

ARG VERSION_OS='3.20'
ARG VERSION_PHP='8.3'

LABEL \
    ALPINE="$VERSION_OS" \
    PHP_VERSION="$VERSION_PHP" \
    MAINTAINER='Samuel Fontebasso <samuel.txd@gmail.com>'

RUN set -eux; \
    apk update; \
    apk add --no-cache --upgrade \
       bzip2-dev \
       ca-certificates \
       curl \
       curl-dev \
       freetype-dev \
       ghostscript \
       git \
       icu-dev \
       imagemagick \
       imagemagick-dev \
       imagemagick-libs \
       jpeg-dev \
       libjpeg-turbo-dev \
       libmcrypt-dev \
       libpng-dev \
       libxml2-dev \
       libzip-dev \
       ncurses \
       nginx \
       nginx-mod-http-headers-more \
       oniguruma-dev \
       openssl \
       runit \
       sqlite; \
    apk add --no-cache --virtual .build-deps \
       build-base \
       gcc \
       wget \
       autoconf \
       linux-headers; \
    docker-php-ext-configure gd \
      --with-freetype \
      --with-jpeg; \
    docker-php-ext-configure pcntl \
      --enable-pcntl; \
    docker-php-ext-install \
        bcmath \
        bz2 \
        calendar \
        exif \
        gd \
        opcache \
        pcntl \
        pdo_mysql \
        shmop \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        zip; \
    pecl install grpc; \
    git clone https://github.com/Imagick/imagick.git --depth 1 /tmp/imagick; \
    cd /tmp/imagick; \
    phpize; \
    ./configure; \
    make -j$(nproc); \
    make install; \
    docker-php-ext-enable --ini-name docker-php-ext-x-01-imagick.ini imagick; \
    docker-php-ext-enable --ini-name docker-php-ext-x-02-grpc.ini grpc; \
    apk del .build-deps; \
    rm -rf /var/cache/apk/* /tmp/imagick; \
    ln -sf /dev/stdout /var/log/nginx/access.log; \
    ln -sf /dev/stderr /var/log/nginx/error.log; \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini";

COPY ./src /
COPY ./custom_params.ini /usr/local/etc/php/conf.d/docker-php-ext-x-02-custom-params.ini

RUN set -eux; \
    touch /env; \
    chown -R www-data:www-data /env /app /var/log/nginx /etc/service /var/run /var/lib/nginx /run/nginx;

RUN chmod +x \
   /sbin/runit-wrapper \
   /sbin/runsvdir-start \
   /etc/service/nginx/run \
   /etc/service/php-fpm/run

USER www-data
WORKDIR /app
EXPOSE 80/tcp

CMD ["/sbin/runit-wrapper"]
