# Utiliser une image de base qui inclut PHP et PHP-FPM
FROM php:8.5-fpm-alpine

# Installez les dépendances du système (nginx, et les extensions PHP)
RUN apk add --no-cache nginx \
    php85-fpm \
    php85-pdo_mysql \
    php85-dom \
    php85-mbstring \
    # Ajoutez toutes les autres extensions PHP nécessaires à votre projet

# Définir le répertoire de travail
WORKDIR /var/www/html

# Copier le code de l'application
COPY . /var/www/html

# Gérer les permissions Laravel (très important)
RUN chown -R www-data:www-data storage bootstrap/cache
RUN chmod -R 775 storage bootstrap/cache

# Copier la configuration Nginx personnalisée
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exposer le port par défaut de Nginx (qui sera géré par Railway)
EXPOSE 8080

# Commande de démarrage : lance à la fois PHP-FPM et Nginx
CMD sh -c "php-fpm && nginx -g 'daemon off;'"
