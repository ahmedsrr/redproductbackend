

FROM php:8.2-fpm

# --- ÉTAPE 1: Installation des outils de compilation et des dépendances ---
# Ajout des paquets de développement pour toutes les extensions (lib*-dev)
# et les outils de compilation (build-essential, autoconf).
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip \
    libzip-dev \
    libonig-dev \
    libpng-dev \
    libjpeg-dev \
    libxml2-dev \
    build-essential \
    autoconf \
    && rm -rf /var/lib/apt/lists/*

# --- ÉTAPE 2: Installation de TOUTES les extensions PHP de Laravel ---
# Installation atomique des extensions critiques.
RUN docker-php-ext-configure gd --with-webp --with-jpeg \
    && docker-php-ext-configure zip \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        mbstring \
        zip \
        gd \
        tokenizer \
        xml

# --- ÉTAPE 3: Installation de Composer ---
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copie des fichiers de l'application
COPY . .

# --- ÉTAPE 4: Installation des dépendances Composer ---
RUN composer install --no-dev --optimize-autoloader

# --- ÉTAPE 5: Configuration des permissions et du cache ---
# Création du cache de configuration pour la performance en production
RUN php artisan config:cache
# Le user par défaut est 'www-data' dans l'image FPM
RUN chown -R www-data:www-data /var/www/storage \
    && chown -R www-data:www-data /var/www/bootstrap/cache

# Point d'entrée pour php-fpm
CMD ["php-fpm"]
