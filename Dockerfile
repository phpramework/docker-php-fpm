FROM php:7.0.12-fpm-alpine

MAINTAINER phpramework <phpramework@gmail.com>

RUN apk update --no-cache \
    && apk add --no-cache \
        icu-dev \
        su-exec \
        tar

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
    && curl -L https://s3-eu-west-1.amazonaws.com/tideways/extension/4.0.6/tideways-php-4.0.6-x86_64.tar.gz > /tmp/tideways-php-4.0.6-x86_64.tar.gz \
    && tar xvfz /tmp/tideways-php-4.0.6-x86_64.tar.gz -C /opt \
    && cd /opt/tideways-php-4.0.6 \
    && ./install.sh

RUN printf "date.timezone = UTC\n" >> $PHP_INI_DIR/conf.d/99-custom.ini
RUN printf "apc.enable_cli = 1\n" >> $PHP_INI_DIR/conf.d/99-custom.ini

RUN mkdir -p /project

VOLUME ["/project"]
WORKDIR /project

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

CMD ["entrypoint.sh", "php-fpm"]
