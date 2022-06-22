ARG NAME_IMAGE_BASE='php'
ARG NAME_IMAGE_TAG='8.1-fpm-alpine3.15'

FROM ${NAME_IMAGE_BASE}:${NAME_IMAGE_TAG}

ARG BUILD_ID="unknown"
ARG COMMIT_ID="unknown"
ARG VERSION_OS='3.15'
ARG VERSION_PHP='8.1'

LABEL \
    ALPINE="$VERSION_OS" \
    BUILD_ID="$BUILD_ID" \
    COMMIT_ID="$COMMIT_ID" \
    MAINTAINER='Samuel Fontebasso <samuel.txd@gmail.com>' \
    PHP_VERSION="$VERSION_PHP"

RUN set -ex; \
    \
    apk add --no-cache --upgrade git \
        bzip2-dev \
        ca-certificates \
        curl \
        curl-dev \
        ghostscript \
        icu-dev \
        imagemagick \
        imagemagick-dev \
        imagemagick-libs \
        libjpeg-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libressl-dev \
        libxml2-dev \
        libzip-dev \
        nginx \
        nginx-mod-http-headers-more \
        oniguruma-dev \
        postgresql-dev \
        runit; \
    apk add --no-cache --virtual build-dependencies build-base gcc wget autoconf; \
    docker-php-ext-install \
        bcmath \
        bz2 \
        calendar \
        exif \
        opcache \
        pdo_mysql \
        pdo_pgsql \
        shmop \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        zip; \
    pecl install imagick; \
    docker-php-ext-enable --ini-name docker-php-ext-x-01-imagick.ini imagick; \
    ln -sf /dev/stdout /var/log/nginx/access.log; \
    ln -sf /dev/stderr /var/log/nginx/error.log; \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini";

COPY ./src /
COPY ./custom_params.ini /usr/local/etc/php/conf.d/docker-php-ext-x-02-custom-params.ini

RUN chmod +x \
   /sbin/runit-wrapper \
   /sbin/runsvdir-start \
   /etc/service/nginx/run \
   /etc/service/php-fpm/run

WORKDIR /app
EXPOSE 80/tcp

CMD ["/sbin/runit-wrapper"]
