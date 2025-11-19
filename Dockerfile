FROM php:8.2-fpm

# Arguments defined in docker-compose.yml
ARG user=www-data
ARG uid=1000

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/composer

RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \
    libicu-dev \
    libssl-dev \
    nano \
    vim \
    locales \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mbstring exif pcntl bcmath zip intl xml

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u ${uid} -d /home/${user} ${user} || true

WORKDIR /var/www/html

# Copy existing application directory contents
COPY . /var/www/html

# Ensure storage and bootstrap cache directories exist
RUN mkdir -p /var/www/html/storage /var/www/html/bootstrap/cache \
    && chown -R ${user}:${user} /var/www/html/storage /var/www/html/bootstrap/cache

# Install PHP dependencies (production/vendor can be rebuilt at runtime if needed)
RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev || true

# Expose port 9000 and start php-fpm
EXPOSE 9000

USER ${user}

CMD ["php-fpm"]
