<?php

use Illuminate\Foundation\Application;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Determine if the application is in maintenance mode...
if (file_exists($maintenance = __DIR__.'/../storage/framework/maintenance.php')) {
    require $maintenance;
}

// Register the Composer autoloader...
require __DIR__.'/../vendor/autoload.php';
<?php
// index.php (ou le fichier principal qui reçoit toutes les requêtes)

// ----------------------------------------------------
// 1. Chargement des dépendances et du .env
// ----------------------------------------------------
require 'vendor/autoload.php';

// Charger les variables du fichier .env
$dotenv = Dotenv\Dotenv::createImmutable(DIR);
$dotenv->load();

// Récupérer les origines nécessaires
$allowedOrigin = $_ENV['FRONTEND_URL_PROD']; 
$requestOrigin = $_SERVER['HTTP_ORIGIN'] ?? '';

// Vérifier si l'origine est autorisée
$isOriginAllowed = ($requestOrigin === $allowedOrigin);

// ----------------------------------------------------
// 2. 🔑 GESTION DES REQUÊTES CORS (EMPLACEMENT CRITIQUE)
// ----------------------------------------------------

// Si l'origine n'est pas autorisée ET que ce n'est pas une requête du même domaine (local), on bloque immédiatement
if (!$isOriginAllowed && !empty($requestOrigin)) {
    http_response_code(403); // Forbidden
    exit();
}

// GESTION DE LA PRÉ-VÉRIFICATION OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    if ($isOriginAllowed) {
        // En-têtes OPTIONS (votre code)
        header("Access-Control-Allow-Origin: $allowedOrigin");
        header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH");
        header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
        header("Access-Control-Allow-Credentials: true"); 
        header("Access-Control-Max-Age: 86400");
        
        http_response_code(204); // Réponse standard
    } else {
        http_response_code(403);
    }
    // Arrêter l'exécution après la réponse OPTIONS
    exit(); 
}

// ----------------------------------------------------
// 3. EN-TÊTES POUR LES REQUÊTES RÉELLES (GET, POST, etc.)
// ----------------------------------------------------

// Définir l'origine pour la requête réelle (doit être fait avant tout output)
if ($isOriginAllowed) {
    header("Access-Control-Allow-Origin: $allowedOrigin");
    header('Access-Control-Allow-Credentials: true');
}

// Définir le type de contenu de la réponse API (JSON)
header('Content-Type: application/json');

// ----------------------------------------------------
// 4. Logique de Routage et Traitement Métier
// ----------------------------------------------------

// Ici commence votre logique de routeur/contrôleur...
// Exemple de login (POST)
if ($_SERVER['REQUEST_METHOD'] === 'POST' && strpos($_SERVER['REQUEST_URI'], '/login') !== false) {
    // ... traitement du login ...
    echo json_encode(['success' => true, 'token' => '...']);
} 
// ... autres routes
// Bootstrap Laravel and handle the request...
/** @var Application $app */
$app = require_once __DIR__.'/../bootstrap/app.php';

$app->handleRequest(Request::capture());
?>
