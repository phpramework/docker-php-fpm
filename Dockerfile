FROM php:7.0.12-fpm-alpine

MAINTAINER phpramework <phpramework@gmail.com>

RUN apk update --no-cache \
    && apk add --no-cache \
        su-exec

RUN apk add --no-cache  --virtual .pecl-deps \
        autoconf \
        gcc \
        make \
        musl-dev \
    && pecl install --onlyreqdeps apcu \
    && docker-php-ext-enable apcu \
    && docker-php-ext-install \
        mysqli \
        opcache \
        pdo_mysql \
    && apk del --no-cache --purge -r .pecl-deps

RUN printf "date.timezone = UTC\n" > $PHP_INI_DIR/conf.d/timezone-utc.ini

RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini

RUN mkdir -p /project

VOLUME ["/project"]
WORKDIR /project

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

CMD ["entrypoint.sh", "php-fpm"]
