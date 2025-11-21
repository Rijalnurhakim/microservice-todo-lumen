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

EXPOSE 8001

CMD ["php", "-S", "0.0.0.0:8001", "-t", "public"]
