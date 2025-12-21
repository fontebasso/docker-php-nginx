ARG ALPINE_VERSION=3.22
ARG PHP_VERSION=8.4.16
ARG NGINX_VERSION=1.29.4

FROM alpine:${ALPINE_VERSION} AS builder
ARG PHP_VERSION
ARG NGINX_VERSION

ENV APP_DIR="/app"

RUN set -eux; \
  apk add --no-cache \
    ca-certificates \
    curl \
    git \
    libarchive-tools \
    tzdata \
    zlib \
    openssl \
    sqlite-libs

RUN set -eux; \
  apk add --no-cache --virtual .build-nginx-deps \
    build-base \
    binutils \
    openssl-dev \
    pcre2-dev \
    zlib-dev; \
  curl -fsSL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o /tmp/nginx.tar.gz; \
  curl -fsSL https://github.com/openresty/headers-more-nginx-module/archive/refs/tags/v0.38.tar.gz -o /tmp/headers-more.tar.gz; \
  bsdtar -xf /tmp/nginx.tar.gz -C /tmp; \
  bsdtar -xf /tmp/headers-more.tar.gz -C /tmp; \
  cd /tmp/nginx-${NGINX_VERSION}; \
  ./configure \
    --add-module=/tmp/headers-more-nginx-module-0.38 \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --prefix=/opt/nginx \
    --with-cc-opt='-O2 -fPIC -fstack-protector-strong' \
    --with-ld-opt='-Wl,-z,relro,-z,now' \
    --with-http_gzip_static_module \
    --with-pcre \
    --with-http_realip_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-threads; \
  make -j$(nproc); \
  make install; \
  strip /opt/nginx/sbin/nginx || true; \
  rm -rf /tmp/nginx*; \
  apk del .build-nginx-deps

RUN set -eux; \
  apk add --no-cache --virtual .build-php-deps \
    abseil-cpp-dev \
    autoconf \
    binutils \
    bzip2-dev \
    c-ares-dev \
    curl-dev \
    freetype-dev \
    g++ \
    gcc \
    jpeg-dev \
    libedit-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libsodium-dev \
    libwebp-dev \
    libxml2-dev \
    libxpm-dev \
    libzip-dev \
    linux-headers \
    make \
    oniguruma-dev \
    openssl-dev \
    pkgconf \
    re2-dev \
    sqlite-dev \
    zlib-dev; \
  curl -fsSL https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz -o /tmp/php.tar.gz; \
  bsdtar -xf /tmp/php.tar.gz -C /tmp; \
  cd /tmp/php-${PHP_VERSION}; \
  export CFLAGS="-O2 -fPIC -fstack-protector-strong -D_FORTIFY_SOURCE=2"; \
  export LDFLAGS="-Wl,-z,relro,-z,now"; \
  ./configure \
    --disable-cgi \
    --disable-phpdbg \
    --enable-bcmath \
    --enable-calendar \
    --enable-exif \
    --enable-fpm \
    --enable-gd \
    --enable-mbstring \
    --enable-opcache \
    --enable-pcntl \
    --enable-pdo \
    --enable-shmop \
    --enable-sockets \
    --enable-sysvmsg \
    --enable-sysvsem \
    --enable-sysvshm \
    --prefix=/opt/php \
    --with-bz2 \
    --with-config-file-scan-dir=/opt/php/etc/php/conf.d \
    --with-curl \
    --with-freetype \
    --with-jpeg \
    --with-libedit \
    --with-openssl \
    --with-pdo-mysql \
    --with-pdo-sqlite \
    --with-sodium \
    --with-webp \
    --with-xpm \
    --with-zip \
    --with-zlib; \
  make -j$(nproc); \
  make install; \
  cp sapi/fpm/php-fpm.conf /opt/php/etc/php-fpm.conf; \
  cp sapi/fpm/www.conf /opt/php/etc/php-fpm.d/www.conf; \
  cp php.ini-production /opt/php/lib/php.ini; \
  mkdir -p /opt/php/etc/php/conf.d; \
  export PHPIZE=/opt/php/bin/phpize; \
  export PHP_CONFIG=/opt/php/bin/php-config; \
  printf "\n" | /opt/php/bin/pecl install grpc; \
  echo "extension=grpc.so" > /opt/php/etc/php/conf.d/php-02-grpc.ini; \
  strip /opt/php/bin/php || true; \
  strip /opt/php/sbin/php-fpm || true; \
  find /opt/php/lib/php/extensions -name "*.so" -exec strip {} \; || true; \
  rm -rf /opt/php/bin/pecl /opt/php/bin/pear /opt/php/bin/peardev \
         /opt/php/bin/phar /opt/php/bin/phar.phar \
         /opt/php/include /opt/php/share; \
  rm -rf /tmp/php*; \
  apk del .build-php-deps

FROM alpine:${ALPINE_VERSION}
ARG ALPINE_VERSION
ARG PHP_VERSION
ARG NGINX_VERSION

LABEL \
  org.opencontainers.image.title="PHP + NGINX (compiled from source)" \
  org.opencontainers.image.description="Image built from Alpine with PHP and NGINX compiled from source using only permissive licenses (MIT/BSD/Apache)" \
  org.opencontainers.image.source="https://github.com/fontebasso/docker-php-nginx" \
  org.opencontainers.image.licenses="MIT" \
  maintainer="Samuel Fontebasso <samuel.txd@gmail.com>" \
  alpine="${ALPINE_VERSION}" \
  php_version="${PHP_VERSION}" \
  nginx_version="${NGINX_VERSION}"

ENV APP_DIR="/app"

RUN set -eux; \
  apk add --no-cache \
    ca-certificates \
    runit \
    tzdata \
    openssl \
    zlib \
    freetype \
    libgomp \
    libjpeg-turbo \
    libpng \
    libsodium \
    libwebp \
    libxml2 \
    libxpm \
    libzip \
    oniguruma \
    sqlite-libs

COPY --from=builder /opt/php /opt/php
COPY --from=builder /opt/nginx /opt/nginx
COPY ./src /
COPY ./custom_params.ini /opt/php/etc/php/conf.d/php-03-custom-params.ini

RUN set -eux; \
  ln -s /opt/php/bin/php /usr/bin/php; \
  ln -s /opt/php/sbin/php-fpm /usr/sbin/php-fpm; \
  ln -s /opt/nginx/sbin/nginx /usr/sbin/nginx; \
  touch /env; \
  chmod +x \
    /sbin/runit-wrapper \
    /sbin/runsvdir-start \
    /etc/service/*/run; \
  adduser -S www-data -G www-data; \
  mkdir -p \
    /run/nginx \
    /var/log/nginx \
    /opt/nginx/client_body_temp; \
  chown -R www-data:www-data \
    /app /env /etc/service /opt/nginx /var/log/nginx /opt/php /tmp /run/nginx

USER www-data
WORKDIR /app
EXPOSE 80
CMD ["/sbin/runit-wrapper"]
