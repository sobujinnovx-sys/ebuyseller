FROM php:8.2-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libzip-dev zip \
    && docker-php-ext-install pdo pdo_mysql mbstring zip exif \
    && docker-php-ext-enable exif

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy application files
COPY . .

# Install PHP dependencies (for production)
RUN composer install --no-dev --optimize-autoloader

# Ensure Laravel storage symlink exists
RUN php artisan storage:link || true

# Laravel permissions
RUN chmod -R 777 storage bootstrap/cache

# Render provides PORT automatically
ENV PORT=8080

# Expose the port
EXPOSE 8080

# Start Laravel
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8080"]
