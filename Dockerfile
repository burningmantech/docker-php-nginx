ARG PHP_VERSION=8
ARG OS_NAME=alpine
ARG OS_VERSION

FROM php:${PHP_VERSION}-fpm-${OS_NAME}${OS_VERSION}

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
