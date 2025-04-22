ARG NAME_IMAGE_BASE='php'
ARG NAME_IMAGE_TAG='8.3-fpm-alpine3.20'

FROM ${NAME_IMAGE_BASE}:${NAME_IMAGE_TAG}

ARG VERSION_OS='3.20'
ARG VERSION_PHP='8.3'
ARG VERSION='unknown'

LABEL \
    org.opencontainers.image.title="PHP + NGINX" \
    org.opencontainers.image.description="Lightweight and secure image with PHP 8.3 and NGINX on Alpine" \
    org.opencontainers.image.source="https://github.com/fontebasso/docker-php-nginx" \
    org.opencontainers.image.version="${VERSION}" \
    org.opencontainers.image.licenses="MIT" \
    maintainer="Samuel Fontebasso <samuel.txd@gmail.com>" \
    alpine="${VERSION_OS}" \
    php_version="${VERSION_PHP}"

ENV APP_DIR="/app"

RUN set -eux; \
    apk update; \
    apk add --no-cache \
      ca-certificates \
      curl \
      git \
      icu-dev \
      imagemagick \
      jpeg-dev \
      freetype-dev \
      libpng-dev \
      libxml2-dev \
      libzip-dev \
      oniguruma-dev \
      sqlite \
      nginx \
      nginx-mod-http-headers-more \
      runit \
      openssl \
      libjpeg-turbo-dev \
      ncurses; \
    apk add --no-cache --virtual .build-deps \
      build-base \
      autoconf \
      linux-headers \
      bzip2-dev \
      curl-dev \
      libmcrypt-dev \
      imagemagick-dev \
      wget \
      gcc; \
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-configure pcntl --enable-pcntl; \
    docker-php-ext-install -j$(nproc) \
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
    git clone --depth=1 https://github.com/Imagick/imagick.git /tmp/imagick; \
    cd /tmp/imagick; \
    phpize; \
    ./configure; \
    make -j$(nproc); \
    make install; \
    docker-php-ext-enable --ini-name docker-php-ext-x-01-imagick.ini imagick; \
    rm -rf /tmp/imagick; \
    pecl install grpc; \
    docker-php-ext-enable --ini-name docker-php-ext-x-02-grpc.ini grpc; \
    apk del .build-deps; \
    rm -rf /var/cache/apk/*; \
    rm -rf /tmp/*; \
    rm -f /var/log/nginx/access.log; \
    ln -sf /dev/null /var/log/nginx/access.log; \
    ln -sf /dev/stderr /var/log/nginx/error.log; \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY ./src /
COPY ./custom_params.ini /usr/local/etc/php/conf.d/docker-php-ext-x-03-custom-params.ini

RUN set -eux; \
    touch /env; \
    chown -R www-data:www-data /env /app /var/log/nginx /etc/service /var/run /var/lib/nginx /run/nginx; \
    chmod +x \
      /sbin/runit-wrapper \
      /sbin/runsvdir-start \
      /etc/service/nginx/run \
      /etc/service/php-fpm/run

USER www-data
WORKDIR /app
EXPOSE 80/tcp

CMD ["/sbin/runit-wrapper"]
