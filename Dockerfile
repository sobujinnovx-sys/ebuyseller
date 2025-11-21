FROM php:8.2-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libzip-dev zip \
    && docker-php-ext-install pdo pdo_mysql mbstring zip exif \
    && docker-php-ext-enable exif

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy application
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Render assigns PORT automatically
ENV PORT=8080

EXPOSE 8080

# Start Laravel's built-in server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8080"]
