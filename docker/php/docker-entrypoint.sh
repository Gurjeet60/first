#!/bin/sh
set -e

echo "======================================"
echo "Starting Laravel Container..."
echo "======================================"

cd /var/www/html

# Fix permissions
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Clear old caches
php artisan optimize:clear

# Run migrations
php artisan migrate --force || true

# Rebuild caches
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Laravel initialization completed."

exec "$@"
