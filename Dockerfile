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
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html

# Copy composer files first (cache optimization)
COPY composer.json composer.lock ./

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copy the rest of the application
COPY . .

# Set permissions for Laravel
RUN mkdir -p storage bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Run Laravel commands
RUN php artisan key:generate || true \
    && php artisan config:cache || true \
    && php artisan route:cache || true \
    && php artisan view:cache || true \
    && php artisan storage:link || true \
    && composer dump-autoload -o

# Copy Nginx configuration
COPY ./docker/nginx/default.conf /etc/nginx/sites-available/default

# Expose HTTP port
EXPOSE 80

# Start PHP-FPM and Nginx in the foreground (Render-friendly)
CMD ["sh", "-c", "php-fpm -F & nginx -g 'daemon off;'"]
