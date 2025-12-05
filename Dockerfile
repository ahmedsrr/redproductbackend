FROM php:8.2-fpm

# -----------------------------------------------------
# 1) Dépendances système nécessaires pour Laravel
# -----------------------------------------------------
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libwebp-dev \
    libzip-dev \
    libxml2-dev \
    libonig-dev \
    unzip \
    git \
    curl \
    && docker-php-ext-configure gd --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        mbstring \
        zip \
        gd \
        tokenizer \
        xml

# -----------------------------------------------------
# 2) Installer Composer
# -----------------------------------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# -----------------------------------------------------
# 3) Définir le dossier de travail
# -----------------------------------------------------
WORKDIR /var/www/html

# -----------------------------------------------------
# 4) Copier les fichiers Laravel
# -----------------------------------------------------
COPY . .

# -----------------------------------------------------
# 5) Installer les dépendances Laravel
# -----------------------------------------------------
RUN composer install --no-dev --optimize-autoloader

# -----------------------------------------------------
# 6) Donner les permissions nécessaires
# -----------------------------------------------------
RUN chown -R www-data:www-data storage bootstrap/cache

# -----------------------------------------------------
# 7) Lancer PHP-FPM
# -----------------------------------------------------
CMD ["php-fpm"]
