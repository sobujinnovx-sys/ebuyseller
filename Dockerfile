# Stage 1: PHP-FPM with dependencies
FROM php:8.2-fpm

# Install system dependencies
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

# Set working directory
WORKDIR /var/www/html

# Copy full application first (artisan and all source files)
COPY . .

# Copy Composer binary from official Composer image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Set permissions for Laravel
RUN mkdir -p storage bootstrap/cache \
    && chown -R www-data:www-data . \
    && chmod -R 775 storage bootstrap/cache

# Copy Nginx configuration
COPY ./docker/nginx/default.conf /etc/nginx/sites-available/default

# Expose HTTP port
EXPOSE 80

# Start PHP-FPM and Nginx
CMD ["sh", "-c", "service nginx start && php-fpm"]
