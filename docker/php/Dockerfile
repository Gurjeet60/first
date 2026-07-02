# ============================================================
# Laracoffee — Production-ready PHP 8.4 + Apache image
# Repo: https://github.com/snykk/Laracoffee
# ============================================================

FROM php:8.4-apache
LABEL maintainer="Gurjeet Singh"

# ──────────────────────────────────────────────────────────────
# 1. System packages
# ──────────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
        git \
        unzip \
        zip \
        curl \
        nano \
        vim \
        libzip-dev \
        libpng-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        libonig-dev \
        libxml2-dev \
        libicu-dev \
        libpq-dev \
        default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# ──────────────────────────────────────────────────────────────
# 2. PHP extensions
# ──────────────────────────────────────────────────────────────
RUN docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        mysqli \
        mbstring \
        zip \
        bcmath \
        intl \
        gd \
        exif

# ──────────────────────────────────────────────────────────────
# 3. Apache — enable mod_rewrite & headers
# ──────────────────────────────────────────────────────────────
RUN a2enmod rewrite headers

# ──────────────────────────────────────────────────────────────
# 4. Node.js 20 + npm (for npm run build / vite)
# ──────────────────────────────────────────────────────────────
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm \
    && rm -rf /var/lib/apt/lists/*

# ──────────────────────────────────────────────────────────────
# 5. Composer
# ──────────────────────────────────────────────────────────────
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ──────────────────────────────────────────────────────────────
# 6. Apache virtualhost
# ──────────────────────────────────────────────────────────────
COPY docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf

# ──────────────────────────────────────────────────────────────
# 7. Working directory
# ──────────────────────────────────────────────────────────────
WORKDIR /var/www/html

# ──────────────────────────────────────────────────────────────
# 8. Copy source — composer deps installed INSIDE the image so
#    vendor/ is baked in and never overwritten by a bind-mount
# ──────────────────────────────────────────────────────────────
COPY . .

# Install PHP dependencies (production, optimised autoloader)
RUN composer install \
        --no-dev \
        --optimize-autoloader \
        --no-interaction \
        --prefer-dist

# Install & build frontend assets
RUN npm ci && npm run build && rm -rf node_modules

# ──────────────────────────────────────────────────────────────
# 9. Laravel storage directories
# ──────────────────────────────────────────────────────────────
RUN mkdir -p \
        storage/logs \
        storage/framework/cache \
        storage/framework/sessions \
        storage/framework/testing \
        storage/framework/views \
        storage/app/public \
        bootstrap/cache

# ──────────────────────────────────────────────────────────────
# 10. Permissions
# ──────────────────────────────────────────────────────────────
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# ──────────────────────────────────────────────────────────────
# 11. Entrypoint
# ──────────────────────────────────────────────────────────────
COPY docker/php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
