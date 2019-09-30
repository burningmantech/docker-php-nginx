FROM php:7.2-fpm-alpine3.8

# Install Nginx and supervisor
RUN apk add --no-cache nginx supervisor;

# Ngnix needs a run directory
RUN install -d /run/nginx;

# Send log output to supervisord's standard I/O
# (Note that supervisord is process 1)
RUN ln -s /proc/1/fd/1 /var/log/nginx/access.log;
RUN ln -s /proc/1/fd/2 /var/log/nginx/error.log;

# Copy Nginx configuration
COPY ./config/nginx-http.conf          /etc/nginx/conf.d/0-http.conf
COPY ./config/nginx-default.conf       /etc/nginx/conf.d/default.conf

# Copy PHP-FPM configuration
COPY ./config/php-fpm.conf             /usr/local/etc/php-fpm.d/zz-docker_nginx.conf

# Copy Supervisor configuration
COPY ./config/supervisord.conf         /etc/supervisor.d/supervisord.ini
COPY ./config/supervisord-php-fpm.conf /etc/supervisor.d/php-fpm.ini
COPY ./config/supervisord-nginx.conf   /etc/supervisor.d/nginx.ini

# Copy static web content
COPY ./error/400.html /var/www/error/400.html
COPY ./error/403.html /var/www/error/403.html
COPY ./error/404.html /var/www/error/404.html
COPY ./error/405.html /var/www/error/405.html
COPY ./error/500.html /var/www/error/500.html

# Set working directory to where the application lives
WORKDIR /var/www/application

# Set command to run
CMD [ "supervisord", "--nodaemon", "-c", "/etc/supervisord.conf" ]

# Expose HTTP port
EXPOSE 80
