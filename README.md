# PHP + Nginx Docker Image

[![Build Status](https://github.com/burningmantech/docker-php-nginx/workflows/CI%2fCD/badge.svg)](https://github.com/burningmantech/docker-php-nginx/actions)

This repository defines a Docker image used by Burning Man for PHP projects.

It includes:

 * [Alpine Linux](https://www.alpinelinux.org/)
 * [PHP](https://secure.php.net/): The PHP language interpreter and runtime.
 * [PHP-FPM](https://php-fpm.org/): A PHP FastCGI implementation
 * [Nginx](https://nginx.org/): HTTP server.

## Supported versions

PHP    | Nginx  | Operating System
------ | ------ | -----------------
7.2.19 | 1.14.2 | Alpine Linux 3.8
7.2.23 | 1.16.1 | Alpine Linux 3.10
7.3.10 | 1.16.1 | Alpine Linux 3.10
7.4.4 | 1.16.1 | Alpine Linux 3.11
7.4.13 | 1.18.0 | Alpine Linux 3.12
8.0.3 | 1.18.0 | Alpine Linux 3.12
8.0.6 | 1.18.0 | Alpine Linux 3.13

## Usage

This image builds on the the corresponding version of the `fpm-alpine` variant of the [Official PHP Image](https://hub.docker.com/_/php/) on Docker Hub.
It adds the Nginix web server, which is used to vend applications.

This image also adds PHP-FPM, which is used for improving web server performance, and [Supervisor](http://supervisord.org), which is used to run and monitor PHP-FPM and Nginix within containers.

Note that this does not use the `apache` variants of the Official PHP Image, so any reference's in the Official PHP Image's documentation to configuring Apache do not apply here.
See below for instructions on configuring Nginx.

### Content

#### Static Content

The install directory for static content is configured in Nginx as `/var/www/html/` and is published at the root (`/`) URL path by the server.

#### Web Application Content

The install directory for PHP applications is configured in Nginx as `/var/www/application/` and is published at the `/application/` URL path by the server.

#### Error Message Content

The install directory for HTTP error pages is configured in Nginx as `/var/www/error/` and is used internally for [default HTTP error content](error/) by the server.

### Using With A Dockerfile

Create a `Dockerfile` similar to this one:

```dockerfile
FROM php-nginx:7.2-alpine3.8
COPY /path/to/my/php/app /var/www/application
```

Then build the image and run a container:

```console
$ docker build -t my-php-app .
$ docker run --detach --name my-php-app my-php-app
```

### Using Without A Dockerfile

Instead of building and running a new image containing your application, you can mount your application into a new container running this image:

```console
$ docker run --detach --name my-php-app --publish 80:80 --volume /path/to/my/php/app:/var/www/application php-nginx:7.2-alpine3.8
```

This is useful, for example, in a development scenario, where you want to be able to modify your code and see the results without rebuilding an application container.

### Command Line PHP Programs

To run command line PHP programs, see the "With Command Line" section in the [Official PHP Image](https://hub.docker.com/_/php/) documentation.
You may prefer to use the `cli` variant of the Official PHP Image in this case, as you probably don't need PHP-FPM or Nginx.
However, if you are testing a web application that uses this container, you may wish to use the same container for consistency.


## Configuration

### Nginx

The configuration files for Nginx are at `/etc/nginx/`.
This image adds:
 * [`/etc/nginx/conf.d/0-http.conf`](config/nginx-http.conf): Enables gzip.
 * [`/etc/nginx/conf.d/default.conf`](config/nginx-default.conf): Sets up the default web site.

### PHP

The configuration files for PHP are at `/usr/local/etc/php/`.

### PHP-FPM

The configuration files for PHP-FPM are at `/usr/local/etc/php-fpm/`.
This image adds:
 * [`/usr/local/etc/php-fpm.d/zz-docker_nginx.conf`](config/php-fpm.conf): Sets up the listening socket file.

### Supervisor

The configuration files for Supervisor are at `/etc/supervisor.d/`.
This image adds:
 * [`/etc/supervisor.d/php-fpm-nginx.ini`](config/supervisord.conf): Configures Supervisor to run PHP-FPM and Nginx.


## Adding PHP Extensions

This image includes a number of common PHP extensions.
Run `php -m` (or `php -i`) to get a list:

```console
docker run --rm php-fpm:7.2-alpine3.8 php -m
```

To add PHP extensions to your images, see the "How to install more PHP extensions" section in the [Official PHP Image](https://hub.docker.com/_/php/) documentation.
