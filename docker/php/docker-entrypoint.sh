#!/bin/bash

set -e

echo "========================================"
echo " Starting Laravel Container"
echo "========================================"

cd /var/www/html

############################################################
# Create .env if missing
############################################################

if [ ! -f .env ]; then
    echo "Creating .env from .env.example..."
    cp .env.example .env
fi

############################################################
# Make .env writable
############################################################

chmod 664 .env || true

############################################################
# Install Composer dependencies if vendor is missing
############################################################

if [ ! -d vendor ]; then
    echo "Installing Composer dependencies..."
    composer install \
        --no-interaction \
        --prefer-dist \
        --optimize-autoloader
fi

############################################################
# Create Laravel directories
############################################################

mkdir -p storage/logs
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p storage/framework/testing
mkdir -p bootstrap/cache

touch storage/logs/laravel.log

############################################################
# Fix permissions
############################################################

chown -R www-data:www-data storage bootstrap/cache || true

chmod -R 775 storage
chmod -R 775 bootstrap/cache

chmod 664 storage/logs/laravel.log || true

############################################################
# Generate APP_KEY if missing
############################################################

if grep -q "^APP_KEY=$" .env || ! grep -q "^APP_KEY=base64:" .env
then
    echo "Generating APP_KEY..."
    php artisan key:generate --force
else
    echo "APP_KEY already exists."
fi

############################################################
# Clear Laravel caches
############################################################

php artisan optimize:clear || true

############################################################
# Storage Link
############################################################

php artisan storage:link || true

############################################################
# Wait for MySQL
############################################################

echo "Waiting for MySQL..."

until php -r "
try{
    new PDO(
        'mysql:host=' . getenv('DB_HOST') .
        ';port=' . getenv('DB_PORT') .
        ';dbname=' . getenv('DB_DATABASE'),
        getenv('DB_USERNAME'),
        getenv('DB_PASSWORD')
    );
    exit(0);
}catch(Exception \$e){
    exit(1);
}
"
do
    echo "MySQL is unavailable - retrying in 3 seconds..."
    sleep 3
done

echo "MySQL Connected."

############################################################
# Run Database Migration
############################################################

php artisan migrate --force || true

############################################################
# Optimize Laravel
############################################################

php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

############################################################
# Display Laravel Information
############################################################

php artisan --version || true

echo "========================================"
echo " Laravel Container Ready"
echo "========================================"

############################################################
# Start Apache
############################################################

exec "$@"
