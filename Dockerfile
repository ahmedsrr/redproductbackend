FROM php:8.2-fpm

# 1. Installation des dépendances système (apt)
# On installe les bibliothèques de développement (lib*-dev) nécessaires aux extensions.
# On installe aussi les utilitaires nécessaires (git, curl, unzip).
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    libzip-dev \
    # Note: On retire 'zip' ici car nous installons l'extension PHP 'zip' à l'étape suivante.
    # On ajoute la suppression du cache apt pour réduire la taille de l'image.
    && rm -rf /var/lib/apt/lists/*

# 2. Installation et configuration des extensions PHP
# On installe d'abord mbstring, qui est simple.
# Puis on configure explicitement 'zip' avant de l'installer.
RUN docker-php-ext-install mbstring \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www.

# Copy app files
COPY . .

# 3. Installation des dépendances PHP (Composer)
# Assurez-vous que l'environnement 'prod' ou 'no-dev' est utilisé pour l'optimisation.
RUN composer install --no-dev --optimize-autoloader

# 4. Configuration des permissions (Critique pour Laravel)
# Le processus 'php-fpm' (par défaut) peut avoir besoin d'écrire dans storage et cache.
RUN chown -R www-data:www-data /var/www/storage \
    && chown -R www-data:www-data /var/www/bootstrap/cache

# 5. Point d'entrée de l'application
CMD ["php-fpm"]
