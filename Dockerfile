FROM php:8.4-fpm

# -----------------------------------------------------
# Dépendances système COMPLÈTES pour PHP
# -----------------------------------------------------
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libwebp-dev \
    libfreetype6-dev \
    libzip-dev \
    zlib1g-dev \
    libonig-dev \
    libxml2-dev \
    pkg-config \
    unzip \
    git \
    curl \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        mbstring \
        zip \
        gd \
        tokenizer \
        xml

# -----------------------------------------------------
# Composer (image officielle)
# -----------------------------------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

RUN composer install --no-dev --optimize-autoloader

RUN chown -R www-data:www-data storage bootstrap/cache

CMD ["php-fpm"]
