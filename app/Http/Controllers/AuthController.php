<?php

namespace App\Http\Controllers;
use App\Http\Controllers;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    // Inscription
    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6|confirmed', // 'confirmed' exige le champ password_confirmation
        ]);

        // Création de l'utilisateur (Rôle 'user' par défaut)
        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => 'user', 
            // Avatar généré automatiquement avec les initiales
            'avatar' => 'https://ui-avatars.com/api/?name=' . urlencode($validated['name']) . '&background=random',
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
        ], 201);
    }

    // Connexion
    public function login(Request $request)
    {
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json(['message' => 'Identifiants invalides'], 401);
        }

        $user = User::where('email', $request->email)->firstOrFail();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
        ]);
    }

    // Récupérer l'utilisateur courant (Pour le contexte React)
    public function user(Request $request)
    {
        return $request->user();
    }

    // Déconnexion
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Déconnecté avec succès']);
    }

    // Mot de passe oublié (Stub)
    public function forgotPassword(Request $request)
    {
        $request->validate(['email' => 'required|email']);
        
        $user = User::where('email', $request->email)->first();

        // Pour des raisons de sécurité, on ne révèle pas si l'email existe ou non
        if (!$user) {
            return response()->json(['message' => 'Si cet email existe, un lien a été envoyé.']);
        }

        // TODO: Implémenter ici l'envoi réel de l'email via SMTP
        // Password::sendResetLink($request->only('email'));

        return response()->json(['message' => 'Lien de réinitialisation envoyé par email.']);
    }
}