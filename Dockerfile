FROM php:7.1.1-fpm-alpine

MAINTAINER phpramework <phpramework@gmail.com>

ENV TIDEWAYS_VERSION=4.1.1

RUN apk update --no-cache \
    && apk add --no-cache \
        bash \
        coreutils \
        icu-dev \
        su-exec \
        tar \
        tini

RUN apk add --no-cache  --virtual .ext-deps \
        autoconf \
        gcc \
        make \
        musl-dev \
    && pecl install --onlyreqdeps apcu redis \
    && docker-php-ext-enable apcu redis \
    && docker-php-ext-install \
        intl \
        mysqli \
        opcache \
        pdo_mysql \
    && apk del --no-cache --purge -r .ext-deps

RUN mkdir -p /opt \
    && curl -L https://s3-eu-west-1.amazonaws.com/tideways/extension/$TIDEWAYS_VERSION/tideways-php-$TIDEWAYS_VERSION-x86_64.tar.gz > /tmp/tideways-php.tar.gz \
    && tar xvfz /tmp/tideways-php.tar.gz -C /opt \
    && cd /opt/tideways-php-$TIDEWAYS_VERSION \
    && bash install.sh \
    && printf "extension = tideways.so\ntideways.auto_prepend_library=0\n" >> $PHP_INI_DIR/conf.d/tideways.ini

RUN printf "date.timezone = UTC\n" >> $PHP_INI_DIR/conf.d/99-custom.ini \
    && printf "apc.enable_cli = 1\n" >> $PHP_INI_DIR/conf.d/99-custom.ini

VOLUME ["/project"]
WORKDIR /project

ENTRYPOINT ["/sbin/tini", "--"]
