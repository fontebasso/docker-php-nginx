ARG NAME_IMAGE_BASE='php'
ARG NAME_IMAGE_TAG='8.2-fpm-alpine3.16'

FROM ${NAME_IMAGE_BASE}:${NAME_IMAGE_TAG}

ARG VERSION_OS='3.16'
ARG VERSION_PHP='8.2'

LABEL \
    ALPINE="$VERSION_OS" \
    PHP_VERSION="$VERSION_PHP" \
    MAINTAINER='Samuel Fontebasso <samuel.txd@gmail.com>'

RUN set -ex; \
    \
    apk add --no-cache --upgrade git \
        bzip2-dev \
        ca-certificates \
        freetype-dev \
        ghostscript \
        icu-dev \
        imagemagick \
        imagemagick-dev \
        imagemagick-libs \
        jpeg-dev \
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
    apk add --no-cache --virtual build-dependencies build-base gcc wget autoconf linux-headers; \
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
        pdo_mysql \
        shmop \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        pcntl \
        zip; \
    pecl install imagick; \
    docker-php-ext-enable --ini-name docker-php-ext-x-01-imagick.ini imagick; \
    ln -sf /dev/stdout /var/log/nginx/access.log; \
    ln -sf /dev/stderr /var/log/nginx/error.log; \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini";

COPY ./src /
COPY ./custom_params.ini /usr/local/etc/php/conf.d/docker-php-ext-x-02-custom-params.ini

RUN touch /env  \
    && chown -R www-data:www-data /env \
    && chown -R www-data:www-data /app \
    && chown -R www-data:www-data /var/log/nginx \
    && chown -R www-data:www-data /etc/service \
    && chown -R www-data:www-data /var/run \
    && chown -R www-data:www-data /var/lib/nginx \
    && chown -R www-data:www-data /run/nginx

RUN chmod +x \
   /sbin/runit-wrapper \
   /sbin/runsvdir-start \
   /etc/service/nginx/run \
   /etc/service/php-fpm/run

USER www-data

WORKDIR /app
EXPOSE 80/tcp

CMD ["/sbin/runit-wrapper"]
