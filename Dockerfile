# Use PHP-FPM for production
FROM php:8.2-fpm

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libzip-dev zip libexif-dev libonig-dev default-mysql-client libpng-dev libjpeg-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip exif \
    && docker-php-ext-enable exif

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy application files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Set permissions for Laravel storage and cache
RUN php artisan storage:link || true
RUN chmod -R 777 storage bootstrap/cache

# Clear config/cache/routes/views
RUN php artisan config:clear && php artisan route:clear && php artisan view:clear

# Expose PHP-FPM port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
