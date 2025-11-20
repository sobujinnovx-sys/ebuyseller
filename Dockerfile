FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    nginx git curl zip unzip libzip-dev libonig-dev \
    libpng-dev libjpeg62-turbo-dev libxml2-dev supervisor \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

# Set working directory
WORKDIR /var/www/html

# Copy Composer files and install PHP dependencies
COPY composer.json composer.lock ./
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader

# Copy the rest of the application
COPY . .

# Set permissions
RUN mkdir -p storage bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Laravel specific setup
RUN php artisan storage:link || true \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Copy Nginx configuration
COPY ./docker/nginx/default.conf /etc/nginx/sites-available/default

# Expose HTTP port
EXPOSE 80

# Start PHP-FPM and Nginx
CMD ["sh", "-c", "service nginx start && php-fpm"]
