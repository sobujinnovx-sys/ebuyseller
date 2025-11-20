FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    nginx \
    git \
    curl \
    zip \
    unzip \
    libzip-dev \
    libonig-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libxml2-dev \
    supervisor \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

WORKDIR /var/www/html

# Copy composer files first
COPY composer.json composer.lock ./

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copy full app
COPY . .

# Set permissions
RUN mkdir -p storage bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Run artisan
RUN php artisan key:generate || true \
    && php artisan config:cache || true \
    && php artisan route:cache || true \
    && php artisan view:cache || true \
    && php artisan storage:link || true \
    && composer dump-autoload -o

# nginx config
COPY ./docker/nginx/default.conf /etc/nginx/sites-available/default

EXPOSE 80

CMD service nginx start && php-fpm
