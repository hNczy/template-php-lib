ARG PHP_VERSION

FROM php:${PHP_VERSION} as base

# Fix CA certificates & install PHP Xdebug extension
RUN curl -sSL https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions -o - | sh -s \
       @fix_letsencrypt \
       xdebug

# Configure PHP Xdebug extension
RUN echo xdebug.var_display_max_data=-1 >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo xdebug.var_display_max_children=-1 >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini


FROM base as composer
ARG COMPOSER_AUTH
RUN [ ! -n "${COMPOSER_AUTH}" ] \
 && echo 'COMPOSER_AUTH environment is required for build ' \
 && exit 1 \
 || echo 'COMPOSER_AUTH environment is exist. Build continues.'

RUN curl -sSL https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions -o - | sh -s \
       @composer

WORKDIR /app

COPY . .

RUN composer install

FROM base

RUN useradd \
    --create-home \
    --home-dir /home/phpunit \
    --user-group \
    --no-log-init \
    phpunit

USER phpunit

WORKDIR /app

COPY --from=composer /app .

ENTRYPOINT ["php", "-d", "memory_limit=-1", "vendor/bin/phpunit", "--configuration", "phpunit.xml"]
