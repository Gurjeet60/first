FROM php:8.4-apache

LABEL maintainer="Gurjeet Singh"

############################
# Install Linux Packages
############################

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

############################
# Install PHP Extensions
############################

RUN docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg

RUN docker-php-ext-install \
        pdo \
        pdo_mysql \
        mysqli \
        mbstring \
        zip \
        bcmath \
        intl \
        gd \
        exif

############################
# Enable Apache Rewrite
############################

RUN a2enmod rewrite headers

############################
# Install NodeJS 20
############################

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -g npm

############################
# Install Composer
############################

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

############################
# Apache Configuration
############################

COPY docker/apache/000-default.conf \
     /etc/apache2/sites-available/000-default.conf

############################
# Working Directory
############################

WORKDIR /var/www/html

############################
# Copy Project
############################

COPY . .

############################
# Laravel Directories
############################

RUN mkdir -p \
    storage/logs \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/testing \
    storage/framework/views \
    bootstrap/cache

############################
# Permissions
############################

RUN chown -R www-data:www-data \
    storage \
    bootstrap/cache

RUN chmod -R 775 \
    storage \
    bootstrap/cache

############################
# Entrypoint
############################

COPY docker/php/docker-entrypoint.sh \
     /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

############################
# Expose Apache
############################

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["apache2-foreground"]
