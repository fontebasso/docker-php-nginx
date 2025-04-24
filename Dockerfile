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
    bash \
    runit \
    ca-certificates \
    curl \
    git \
    tzdata \
    libevent \
    libzip \
    libedit \
    openssl \
    zlib \
    sqlite-libs \
    oniguruma \
    libarchive-tools;

# --- Build NGINX ---
RUN set -eux; \
  apk add --no-cache --virtual .build-nginx-deps \
    build-base \
    pcre2-dev \
    zlib-dev \
    openssl-dev; \
  curl -fsSL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o /tmp/nginx.tar.gz; \
  curl -fsSL https://github.com/openresty/headers-more-nginx-module/archive/refs/tags/v0.38.tar.gz -o /tmp/headers-more.tar.gz; \
  mkdir -p /tmp/nginx /tmp/headers-more-nginx-module-0.38; \
  bsdtar -xf /tmp/nginx.tar.gz -C /tmp; \
  bsdtar -xf /tmp/headers-more.tar.gz -C /tmp; \
  cd /tmp/nginx-${NGINX_VERSION}; \
  ./configure \
    --prefix=/opt/nginx \
    --with-http_ssl_module \
    --with-http_gzip_static_module \
    --with-http_stub_status_module \
    --with-http_realip_module \
    --with-threads \
    --with-pcre \
    --add-module=/tmp/headers-more-nginx-module-0.38 \
    --with-cc-opt='-O2 -fPIC' \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log; \
  make -j$(nproc); \
  make install; \
  ln -s /opt/nginx/sbin/nginx /usr/sbin/nginx; \
  apk del .build-nginx-deps; \
  rm -rf /tmp/nginx*

# --- Build PHP ---
RUN set -eux; \
  apk add --no-cache --virtual .build-php-deps \
    autoconf \
    bzip2-dev \
    curl-dev \
    libedit-dev \
    libxml2-dev \
    libpng-dev \
    jpeg-dev \
    freetype-dev \
    libsodium-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    libxpm-dev \
    libzip-dev \
    sqlite-dev \
    openssl-dev \
    zlib-dev \
    bzip2-dev \
    oniguruma-dev \
    linux-headers \
    gcc \
    g++ \
    make \
    pkgconf; \
  curl -fsSL https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz -o /tmp/php.tar.gz; \
  bsdtar -xf /tmp/php.tar.gz -C /tmp; \
  cd /tmp/php-${PHP_VERSION}; \
  ./configure \
    --prefix=/opt/php \
    --enable-fpm \
    --enable-gd \
    --with-bz2 \
    --with-freetype \
    --with-jpeg \
    --with-webp \
    --with-xpm \
    --with-png \
    --with-openssl \
    --with-zlib \
    --with-curl \
    --with-sodium \
    --with-libedit \
    --enable-mbstring \
    --enable-bcmath \
    --enable-exif \
    --enable-pcntl \
    --enable-opcache \
    --enable-pdo \
    --enable-shmop \
    --enable-sockets \
    --enable-sysvmsg \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-calendar \
    --with-pdo-mysql \
    --with-pdo-sqlite \
    --with-config-file-scan-dir=/opt/php/etc/conf.d \
    --with-zip \
    --disable-cgi \
    --disable-phpdbg; \
  make -j$(nproc); \
  make install; \
  cp sapi/fpm/php-fpm.conf /opt/php/etc/php-fpm.conf; \
  cp sapi/fpm/www.conf /opt/php/etc/php-fpm.d/www.conf; \
  cp php.ini-production /opt/php/lib/php.ini; \
  ln -s /opt/php/sbin/php-fpm /usr/sbin/php-fpm; \
  ln -s /opt/php/bin/php /usr/bin/php; \
  ln -s /opt/php/bin/phpize /usr/bin/phpize; \
  ln -s /opt/php/bin/pecl /usr/bin/pecl; \
  ln -s /opt/php/bin/php-config /usr/bin/php-config; \
  mkdir -p /opt/php/etc/conf.d; \
  apk del .build-php-deps; \
  rm -rf /tmp/php*

COPY ./src /
COPY ./custom_params.ini /opt/php/etc/conf.d/php-03-custom-params.ini

RUN set -eux; \
  apk add --no-cache \
    libgomp \
    libheif \
    openjpeg \
    librsvg \
    libsodium \
    libraw \
    libwmf \
    libxml2 \
    sqlite-libs \
    libzip \
    freetype \
    libjpeg-turbo \
    libpng \
    libwebp \
    libxpm \
    oniguruma \
    libarchive-tools; \
  apk del bash; \
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
