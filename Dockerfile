FROM php:8.4-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libonig-dev libzip-dev zip \
    && docker-php-ext-install pdo pdo_mysql mbstring zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# 1. Mise à jour des listes de paquets et installation de pgsql
RUN apt-get update \
    && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo_pgsql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copie le code source complet AVANT d'installer les dépendances
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Laravel setup
RUN php artisan config:clear && \
    php artisan route:clear && \
    php artisan view:clear

# 🛑 AJOUT CRITIQUE POUR LE LIEN SYMBOLIQUE
# Exécute la liaison du stockage. Cette commande DOIT être exécutée APRÈS composer install
# car elle utilise les helpers de Laravel.
RUN php artisan storage:link

EXPOSE 8080

# 🛑 CORRECTION CMD : Utilisation de la variable $PORT par défaut de Railway
CMD php artisan serve --host=0.0.0.0 --port=${PORT:-8080}
