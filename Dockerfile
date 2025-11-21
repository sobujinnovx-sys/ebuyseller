# Stage 1: PHP + Composer
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libonig-dev libzip-dev zip nginx supervisor \
    && docker-php-ext-install pdo pdo_mysql mbstring zip exif \
    && docker-php-ext-enable exif

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy application files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --ignore-platform-req=ext-exif

# Set permissions
RUN php artisan storage:link || true
RUN chmod -R 777 storage bootstrap/cache

# Clear caches
RUN php artisan config:clear && php artisan route:clear && php artisan view:clear

# Copy Nginx & Supervisor config
COPY ./docker/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY ./docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Render assigns PORT automatically
ENV PORT=8080

# Expose port
EXPOSE 8080

# Start Supervisor
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
