# 1. Image de base et installation des outils (Extensions, Composer)
FROM php:8.3-fpm-alpine # Exemple : utilisez votre version PHP

# ... (Installation des extensions et de Composer ici) ...

# 2. Définir le répertoire de travail
WORKDIR /app

# 3. Copier les fichiers clés (pour le cache Docker)
COPY composer.json composer.lock ./

# 4. Installer les dépendances (doit se faire APRES l'installation de Composer)
RUN composer install --no-dev --optimize-autoloader

# 5. Copier le reste du code
COPY . .

# 6. Exécuter les commandes de mise en cache (optionnel, mais rapide)
# Vous devez utiliser "php /app/artisan" si Artisan n'est pas dans le PATH
RUN php artisan config:cache && php artisan route:cache

# 7. Exposer le port et démarrer le processus
EXPOSE 9000
CMD ["php-fpm"]
