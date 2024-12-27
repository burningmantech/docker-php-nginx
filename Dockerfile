ARG PHP_VERSION=8
ARG OS_NAME=alpine
ARG OS_VERSION

FROM php:${PHP_VERSION}-fpm-${OS_NAME}${OS_VERSION}

# TODO: Use latest released version, after https://github.com/Imagick/imagick/issues/640 is fixed

ADD --chmod=0755 \
      https://github.com/mlocati/docker-php-extension-installer/releases/download/2.6.3/install-php-extensions \
      /usr/local/bin/

# Install OS packages required at runtime
RUN apk update            \
  && apk add --no-cache   \
  git                     \
  icu                     \
  icu-dev                 \
  libffi                  \
  libheif                 \
  libheif-dev             \
  libffi-dev              \
  libjpeg-turbo           \
  libjpeg-turbo-dev       \
  libpng                  \
  libpng-dev              \
  libwebp                 \
  libwebp-dev             \
  libxml2                 \
  libxml2-dev             \
  libzip                  \
  libzip-dev              \
  mysql-client            \
  pcre-dev                \
  tzdata                  \
  vips                    \
  zip                     \
  ${PHPIZE_DEPS}          \
 && docker-php-ext-configure opcache --enable-opcache  \
  && docker-php-ext-configure intl                      \
  && docker-php-ext-configure exif                      \
  && docker-php-ext-install -j$(nproc)                  \
    intl                                                \
    opcache                                             \
    pdo                                                 \
    pdo_mysql                                           \
    zip                                                 \
  && MAKEFLAGS="-j $(nproc)" pecl install --configureoptions 'enable-brotli="no"' swoole \
  && docker-php-ext-enable swoole                       \
  && docker-php-ext-configure pcntl --enable-pcntl      \
  && docker-php-ext-install pcntl                       \
  && docker-php-ext-install -j$(nproc) exif             \
  && docker-php-ext-configure ffi --with-ffi            \
  && docker-php-ext-install -j$(nproc) ffi              \
  && apk del                                            \
    icu-dev                                             \
    libffi-dev                                          \
    libheif-dev                                         \
    libjpeg-turbo-dev                                   \
    libpng-dev                                          \
    libwebp-dev                                         \
    libxml2-dev                                         \
    libzip-dev                                          \
    pcre-dev                                            \
   ${PHPIZE_DEPS}                                       \
                                                        ;

# Install Nginx and supervisor
# Ngnix needs a run directory
# Send log output to supervisord's standard I/O
# (Note that supervisord is process 1)

RUN apk add --no-cache nginx supervisor && \
        install -d /run/nginx && \
        ln -s /proc/1/fd/1 /var/log/nginx/access.log && \
        ln -s /proc/1/fd/2 /var/log/nginx/error.log;

# Copy Nginx configuration
COPY ./config/nginx-http.conf    /etc/nginx/http.d/0-http.conf
COPY ./config/nginx-default.conf /etc/nginx/http.d/default.conf

# Copy PHP-FPM configuration
COPY ./config/php-fpm.conf /usr/local/etc/php-fpm.d/zz-docker_nginx.conf

# Copy Supervisor configuration
COPY ./config/supervisord.conf         /etc/supervisor.d/supervisord.ini
COPY ./config/supervisord-php-fpm.conf /etc/supervisor.d/php-fpm.ini
COPY ./config/supervisord-nginx.conf   /etc/supervisor.d/nginx.ini

# Copy static web content
ADD ./error /var/www/error

# Set working directory to where the application lives
WORKDIR /var/www/application

# Set command to run
CMD [ "supervisord", "--nodaemon", "-c", "/etc/supervisord.conf" ]

# Expose HTTP port
EXPOSE 80
