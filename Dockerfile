FROM php:8.2-fpm

# Install PHP extensions & dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libzip-dev zip libexif-dev libonig-dev nginx \
    && docker-php-ext-install pdo pdo_mysql mbstring zip exif

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . .

RUN composer install --no-dev --optimize-autoloader

RUN php artisan storage:link || true
RUN chmod -R 777 storage bootstrap/cache

# Nginx config
COPY default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Start Nginx and PHP-FPM
CMD ["sh", "-c", "php-fpm & nginx -g 'daemon off;'"]
