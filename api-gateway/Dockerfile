FROM php:8.2-alpine

WORKDIR /app

RUN apk add --no-cache \
    git \
    unzip \
    libzip-dev \
    zip \
    && docker-php-ext-install zip pcntl

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY composer.json composer.lock ./

RUN composer install --no-dev --optimize-autoloader

COPY . .

EXPOSE 8000

CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
