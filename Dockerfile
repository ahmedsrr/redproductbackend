FROM php:8.2-fpm

# 1. Mise à jour et installation des dépendances système
# Ajout de libonig-dev (pour mbstring) et libzip-dev (pour zip)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    libzip-dev \
    libonig-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Installation des extensions PHP requises par Laravel
# AJOUT CRITIQUE : pdo_mysql et tokenizer
RUN docker-php-ext-install mbstring pdo_mysql tokenizer \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy app files
COPY . .

# 3. Installation des dépendances PHP (Composer)
# Note: Vérifiez bien l'orthographe du drapeau ici ! --optimize-autoloader
RUN composer install --no-dev --optimize-autoloader

# 4. Configuration des permissions (Critique pour Laravel)
RUN chown -R www-data:www-data /var/www/storage \
    && chown -R www-data:www-data /var/www/bootstrap/cache

# 5. Point d'entrée de l'application
CMD ["php-fpm"]
