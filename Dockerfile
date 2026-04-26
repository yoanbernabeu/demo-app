# syntax=docker/dockerfile:1
FROM dunglas/frankenphp:1-php8

RUN apt-get update \
 && apt-get install -y --no-install-recommends git unzip \
 && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

COPY composer.json composer.lock symfony.lock ./
RUN composer install --no-dev --no-scripts --no-interaction --prefer-dist --optimize-autoloader

COPY . .

RUN APP_ENV=prod APP_SECRET=build-time-placeholder \
    composer dump-autoload --classmap-authoritative --no-dev \
 && APP_ENV=prod APP_SECRET=build-time-placeholder \
    php bin/console cache:clear --no-debug \
 && APP_ENV=prod APP_SECRET=build-time-placeholder \
    php bin/console cache:warmup --no-debug

ENV APP_ENV=prod \
    APP_DEBUG=0 \
    SERVER_NAME=:80

EXPOSE 80
