FROM php:8.4-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libonig-dev libzip-dev zip \
    && docker-php-ext-install pdo pdo_mysql mbstring zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# 1. Mise à jour des listes de paquets
RUN apt-get update \
    # 2. Installation des paquets nécessaires (libpq-dev pour les outils de développement PostgreSQL)
    && apt-get install -y libpq-dev \
    # 3. Installation de l'extension PHP pdo_pgsql via l'utilitaire Docker
    && docker-php-ext-install pdo_pgsql \
    # 4. Nettoyage pour réduire la taille de l'image
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Laravel setup
RUN php artisan config:clear && \
    php artisan route:clear && \
    php artisan view:clear

EXPOSE 8080

# Assurez-vous que le shell peut interpoler cette variable
CMD php artisan serve --host=0.0.0.0 --port=${PORT:-8080}
