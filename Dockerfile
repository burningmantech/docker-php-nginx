FROM php:7.2-fpm-alpine3.8

# Copy the install script, run it, delete it
COPY ./tools/install /docker_install/install
RUN /docker_install/install && rm -rf /docker_install

# Copy configuration
COPY ./config/php-fpm.conf /usr/local/etc/php-fpm.d/zz-docker_nginx.conf
COPY ./config/supervisord.conf /etc/supervisor.d/php-fpm-nginx.ini

# Copy static web content
COPY ./error/404.html /var/www/html/404.html
COPY ./error/500.html /var/www/html/500.html

# Copy tools
COPY ./tools/checkphpsyntax /usr/local/bin/checkphpsyntax

# Set command to run
CMD [ "supervisord", "--nodaemon", "-c", "/etc/supervisord.conf" ]

# Expose HTTP port
EXPOSE 80
