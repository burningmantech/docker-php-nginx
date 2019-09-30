set -eu

wd="$(cd "$(dirname "$0")/.." && pwd)";

image_repository="php-nginx";

image_versions=$(grep -v '^ *#' "${wd}/versions.txt");

image_tag ()
{
    php_version="${1}"; shift;
        os_name="${1}"; shift;
     os_version="${1}"; shift;

    echo "${php_version}-fpm-${os_name}${os_version}";
}

image_name ()
{
    php_version="${1}"; shift;
        os_name="${1}"; shift;
     os_version="${1}"; shift;

    image_tag="$(image_tag "${php_version}" "${os_name}" "${os_version}")";

    echo "${image_repository}:${image_tag}";
}

container_name="php-nginx";
