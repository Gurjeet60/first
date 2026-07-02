#!/bin/sh

set -e

echo "======================================"
echo "Starting Laravel Container..."
echo "======================================"

# Wait a little for the database
sleep 5

# Generate app key if missing
if ! grep -q "^APP_KEY=base64:" .env; then
    php artisan key:generate --force
fi

# Run migrations
php artisan migrate --force || true

# Cache configuration
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

# Fix permissions
chown -R www-data:www-data storage bootstrap/cache || true
chmod -R 775 storage bootstrap/cache || true

echo "Laravel initialization completed."

exec "$@"
