# syntax=docker/dockerfile:1

# =========================
# Stage 1 — builder
# =========================
FROM dunglas/frankenphp:1-php8 AS builder

ENV APP_ENV=prod \
    APP_DEBUG=0

RUN apt-get update \
 && apt-get install -y --no-install-recommends git unzip \
 && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

COPY composer.json composer.lock symfony.lock ./
RUN composer install --no-dev --no-scripts --no-interaction --prefer-dist --optimize-autoloader \
 && composer clear-cache

COPY . .

RUN APP_SECRET=build-placeholder composer dump-autoload --classmap-authoritative --no-dev \
 && APP_SECRET=build-placeholder php bin/console cache:clear --no-debug \
 && APP_SECRET=build-placeholder php bin/console cache:warmup --no-debug \
 && rm -rf var/cache/dev var/cache/test var/log/* /root/.composer

# =========================
# Stage 2 — runtime
# =========================
FROM dunglas/frankenphp:1-php8

ENV APP_ENV=prod \
    APP_DEBUG=0 \
    SERVER_NAME=:80

WORKDIR /app

COPY --from=builder /app /app

EXPOSE 80
