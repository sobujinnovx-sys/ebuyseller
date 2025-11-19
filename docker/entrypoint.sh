#!/bin/sh
set -e

# Set permissions for Laravel
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache || true
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache || true

# Create storage link if missing
if [ ! -L /var/www/html/public/storage ]; then
  if [ -d /var/www/html/storage/app/public ]; then
    ln -s /var/www/html/storage/app/public /var/www/html/public/storage || true
  fi
fi

exec "$@"
