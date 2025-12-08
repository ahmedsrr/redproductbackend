<?php
namespace App\Http\Controllers;

use App\Models\Hotel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;



class HotelController extends Controller
{
    // Liste des hôtels
    public function index()
    {
        $hotels = Hotel::all();
        
        // Transformer les données pour inclure l'URL complète de l'image
        $hotels->transform(function ($hotel) {
            if ($hotel->image) {
                $hotel->image = url('storage/' . $hotel->image);
            }
            return $hotel;
        });

        return response()->json($hotels);
    }

    // Créer un hôtel avec image
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'address' => 'required|string',
            'email' => 'required|email|max: 255',
            'phone' => 'required|string|max: 255',
            'price' => 'required|string',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'description' => 'nullable|string'
        ]);

        $data = $request->except('image');

        if ($request->hasFile('image')) {
            // Stocke l'image dans storage/app/public/hotels
            $path = $request->file('image')->store('hotels', 'public');
            $data['image'] = $path;
        }

        $hotel = Hotel::create($data);
        
        // Retourne l'URL complète
        if ($hotel->image) {
            $hotel->image = url('storage/' . $hotel->image);
        }

        return response()->json($hotel, 201);
    }
}
