FROM php:8.2-fpm

# 1. Mise à jour et installation des dépendances système
# AJOUT DE 'libonig-dev' (Indispensable pour mbstring)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    libzip-dev \
    libonig-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Installation de l'extension PHP mbstring
# Maintenant que libonig-dev est installé au-dessus, ceci va fonctionner.
RUN docker-php-ext-install mbstring

# 3. Installation et configuration de l'extension PHP zip
RUN docker-php-ext-configure zip \
    && docker-php-ext-install zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy app files
COPY . .

# 4. Installation des dépendances PHP
RUN composer install --no-dev --optimize-autoloader

# 5. Configuration des permissions
RUN chown -R www-data:www-data /var/www/storage \
    && chown -R www-data:www-data /var/www/bootstrap/cache

# 6. Point d'entrée
CMD ["php-fpm"]
