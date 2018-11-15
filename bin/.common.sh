set -eu

wd="$(cd "$(dirname "$0")/.." && pwd)";

image_repo="php-nginx";
 image_tag="$(cat "${wd}/Dockerfile" | grep -e '^FROM ' | sed -e 's|^FROM php:||' -e 's|-fpm||')";
image_name="${image_repo}:${image_tag}";

container_name="php-nginx";
