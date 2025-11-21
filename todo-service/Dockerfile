FROM php:8.2-alpine

WORKDIR /app

RUN apk add --no-cache \
    git \
    unzip \
    libzip-dev \
    zip \
    postgresql-dev \
    && docker-php-ext-install zip pcntl pdo pdo_pgsql

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY composer.json composer.lock ./

RUN composer install --no-dev --optimize-autoloader

COPY . .

EXPOSE 8002

CMD sh -c "php -S 0.0.0.0:8002 -t public & while true; do php artisan schedule:run; sleep 60; done"
