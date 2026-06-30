#!/bin/bash

set -e

echo "========================================="
echo " Laravel CI/CD Cleanup Started"
echo "========================================="

PROJECT_DIR="/var/www/html"

#############################################
# Stop old containers
#############################################

echo "Stopping existing containers..."

docker compose down --remove-orphans || true

#############################################
# Remove dangling containers/images/networks
#############################################

echo "Removing unused Docker resources..."

docker image prune -af || true
docker network prune -f || true
docker builder prune -af || true

#############################################
# Optional
# Uncomment ONLY if you want to delete
# ALL unused Docker volumes.
#############################################

# docker volume prune -f

#############################################
# Laravel Cleanup
#############################################

if [ -d "$PROJECT_DIR" ]; then

    cd "$PROJECT_DIR"

    echo "Cleaning Laravel cache..."

    rm -rf bootstrap/cache/* || true

    rm -rf storage/framework/cache/* || true
    rm -rf storage/framework/sessions/* || true
    rm -rf storage/framework/views/* || true
    rm -rf storage/framework/testing/* || true

    mkdir -p storage/logs
    touch storage/logs/laravel.log

    echo "Cleaning logs..."

    find storage/logs -type f -name "*.log" -delete || true

    touch storage/logs/laravel.log

    echo "Removing old compiled files..."

    rm -f public/storage || true

fi

#############################################
# Optional Clean Build
#############################################

# Uncomment these if you always want
# a fresh Composer install.

# rm -rf vendor
# rm -f composer.lock

#############################################
# Optional Node Cleanup
#############################################

# Uncomment if using Vite or Mix.

# rm -rf node_modules
# rm -rf public/build

#############################################
# Remove temporary files
#############################################

find /tmp -type f -mtime +2 -delete 2>/dev/null || true

#############################################
# Docker Status
#############################################

echo
echo "Docker Status"

docker ps -a || true

echo
echo "Docker Images"

docker images || true

echo
echo "Docker Volumes"

docker volume ls || true

echo
echo "========================================="
echo " Cleanup Completed Successfully"
echo "========================================="
