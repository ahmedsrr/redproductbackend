# 1. Utiliser une version stable (exemple: 8.3)
FROM php:8.3-fpm-alpine

# Définir le répertoire de travail
WORKDIR /var/www/html

# 2. Installez Nginx et les dépendances système
# Note: Pour Postgres, nous avons besoin de postgresql-client
RUN apk update && apk add --no-cache \
    nginx \
    postgresql-client \
    $PHPIZE_DEPS \
    && rm -rf /var/cache/apk/*

# 3. Installer les extensions PHP (Postgres et les autres)
# Les extensions s'appellent pdo_pgsql, pgsql, etc.
RUN docker-php-ext-install pdo_pgsql pgsql dom mbstring

# Copier les fichiers du projet
COPY . /var/www/html

# Gérer les permissions Laravel (www-data est l'utilisateur FPM par défaut)
RUN chown -R www-data:www-data storage bootstrap/cache
RUN chmod -R 775 storage bootstrap/cache

# Copier la configuration Nginx (assurez-vous que ce fichier nginx.conf est correct)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exposer le port pour Nginx
EXPOSE 8080

# Commande de démarrage finale : lance PHP-FPM et Nginx
CMD sh -c "php-fpm && nginx -g 'daemon off;'"
