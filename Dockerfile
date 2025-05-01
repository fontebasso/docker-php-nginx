ARG ALPINE_VERSION=3.21
ARG PHP_VERSION=8.3.20
ARG NGINX_VERSION=1.27.5

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
  ln -sf /bin/false /usr/bin/tar; \
  apk update; \
  apk add --no-cache \
    ca-certificates \
    curl \
    git \
    libarchive-tools \
    libedit \
    libevent \
    libzip \
    oniguruma \
    openssl \
    runit \
    sqlite-libs \
    tzdata \
    zlib;

RUN set -eux; \
  apk add --no-cache --virtual .build-nginx-deps \
    build-base \
    openssl-dev \
    pcre2-dev \
    zlib-dev; \
  curl -fsSL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o /tmp/nginx.tar.gz; \
  curl -fsSL https://github.com/openresty/headers-more-nginx-module/archive/refs/tags/v0.38.tar.gz -o /tmp/headers-more.tar.gz; \
  mkdir -p /tmp/nginx /tmp/headers-more-nginx-module-0.38; \
  bsdtar -xf /tmp/nginx.tar.gz -C /tmp; \
  bsdtar -xf /tmp/headers-more.tar.gz -C /tmp; \
  cd /tmp/nginx-${NGINX_VERSION}; \
  ./configure \
    --add-module=/tmp/headers-more-nginx-module-0.38 \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --prefix=/opt/nginx \
    --with-cc-opt='-O2 -fPIC' \
    --with-http_gzip_static_module \
    --with-pcre \
    --with-http_realip_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-threads; \
  make -j$(nproc); \
  make install; \
  ln -s /opt/nginx/sbin/nginx /usr/sbin/nginx; \
  apk del .build-nginx-deps; \
  rm -rf /tmp/nginx*

RUN set -eux; \
  apk add --no-cache --virtual .build-php-deps \
    abseil-cpp-dev \
    autoconf \
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
    --with-pear \
    --with-png \
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
  ln -s /opt/php/sbin/php-fpm /usr/sbin/php-fpm; \
  ln -s /opt/php/bin/php /usr/bin/php; \
  ln -s /opt/php/bin/phpize /usr/bin/phpize; \
  ln -s /opt/php/bin/php-config /usr/bin/php-config; \
  mkdir -p /opt/php/etc/php/conf.d; \
  printf "\n" | /opt/php/bin/pecl install grpc; \
  echo "extension=grpc.so" > /opt/php/etc/php/conf.d/php-02-grpc.ini; \
  rm -rf /opt/php/bin/pecl /opt/php/bin/pear /opt/php/bin/peardev /opt/php/bin/peclcmd.php /opt/php/bin/pearcmd.php /opt/php/bin/phar /opt/php/bin/phar.phar; \
  find /opt/php -type f -name "peclcmd.php" -delete; \
  find /opt/php -type f -name "pearcmd.php" -delete; \
  find /opt/php -type d -name "pear" -exec rm -rf {} +; \
  apk del .build-php-deps; \
  rm -rf /tmp/php*

COPY ./src /
COPY ./custom_params.ini /opt/php/etc/conf.d/php-03-custom-params.ini

RUN set -eux; \
  apk add --no-cache \
    freetype \
    libgomp \
    libheif \
    libjpeg-turbo \
    libpng \
    libraw \
    librsvg \
    libsodium \
    libwebp \
    libwmf \
    libxml2 \
    libxpm \
    libzip \
    oniguruma \
    openjpeg \
    libarchive-tools \
    sqlite-libs; \
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
