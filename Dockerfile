FROM php:8.2-cli

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libzip-dev zip libexif-dev libpng-dev libjpeg-dev libonig-dev default-mysql-client \
    && docker-php-ext-install pdo pdo_mysql mbstring zip exif \
    && docker-php-ext-enable exif

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy app files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Ensure storage link exists
RUN php artisan storage:link || true

# Permissions
RUN chmod -R 777 storage bootstrap/cache

# Render assigns PORT automatically
ENV PORT=8080

EXPOSE 8080

# Start Laravel built-in server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8080"]
