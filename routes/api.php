<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HotelController;
use App\Http\Controllers\AuthController;

// --- Routes Publiques ---
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);

// --- Routes Protégées (Nécessite Token JWT) ---
Route::group(['middleware' => ['auth:sanctum']], function () {
    
    // Auth
    Route::get('/user', [AuthController::class, 'user']); // Pour api.getMe()
    Route::post('/logout', [AuthController::class, 'logout']);

    // Hôtels
    Route::get('/hotels', [HotelController::class, 'index']); // Liste
    Route::post('/hotels', [HotelController::class, 'store']); // Création (Admin check dans le contrôleur)

    // Produits (Données fictives pour l'instant)
    Route::get('/products', function() {
        return response()->json([
            ['id' => 1, 'name' => 'Produit A', 'price' => 100, 'stock' => 10, 'status' => 'Active'],
        ]);
    });
});