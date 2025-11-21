# Stage 1: Build PHP application
FROM php:8.2-fpm AS builder

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libzip-dev zip libonig-dev libexif-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip exif \
    && docker-php-ext-enable exif

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy application files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Stage 2: Production image
FROM php:8.2-fpm

WORKDIR /var/www

# Install system dependencies and nginx
RUN apt-get update && apt-get install -y \
    nginx supervisor libpq-dev libzip-dev zip libonig-dev libexif-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip exif \
    && docker-php-ext-enable exif

# Copy app from builder stage
COPY --from=builder /var/www /var/www

# Set permissions
RUN chmod -R 777 storage bootstrap/cache

# Copy Nginx config
COPY default.conf /etc/nginx/conf.d/default.conf

# Expose HTTP port
EXPOSE 80

# Start Nginx and PHP-FPM using supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord", "-n"]
