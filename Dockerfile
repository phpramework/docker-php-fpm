FROM php:7.0.12-fpm-alpine

MAINTAINER phpramework <phpramework@gmail.com>

RUN apk update --no-cache \
    && apk add --no-cache \
        icu-dev \
        su-exec

RUN apk add --no-cache  --virtual .ext-deps \
        autoconf \
        gcc \
        make \
        musl-dev \
    && pecl install --onlyreqdeps apcu \
    && docker-php-ext-enable apcu \
    && docker-php-ext-install \
        intl \
        mysqli \
        opcache \
        pdo_mysql \
    && apk del --no-cache --purge -r .ext-deps

RUN printf "date.timezone = UTC\n" >> $PHP_INI_DIR/conf.d/99-custom.ini
RUN printf "apc.enable_cli = 1\n" >> $PHP_INI_DIR/conf.d/99-custom.ini

RUN mkdir -p /project

VOLUME ["/project"]
WORKDIR /project

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

CMD ["entrypoint.sh", "php-fpm"]
