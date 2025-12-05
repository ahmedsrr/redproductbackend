FROM php:8.2-fpm

# 1. Mise à jour des listes et installation des dépendances système
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    libzip-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Installation de l'extension PHP mbstring (isolée)
RUN docker-php-ext-install mbstring

# 3. Installation et configuration de l'extension PHP zip (isolée)
RUN docker-php-ext-configure zip \
    && docker-php-ext-install zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy app files
COPY . .

# 4. Installation des dépendances PHP (Composer)
RUN composer install --no-dev --optimize-autoloader

# 5. Configuration des permissions (Critique pour Laravel)
RUN chown -R www-data:www-data /var/www/storage \
    && chown -R www-data:www-data /var/www/bootstrap/cache

# 6. Point d'entrée de l'application
CMD ["php-fpm"]
