<?php

namespace App\Http\Controllers;

use App\Models\User;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use App\Services\JwtService;

class UserController extends Controller
{
    private $jwtService;

    public function __construct(JwtService $jwtService)
    {
        $this->jwtService = $jwtService;
    }
    public function register(Request $request)
    {
        try {
            $this->validate($request,[
                'name' => 'required|string',
                'email' => 'required|string|unique:users',
                'password' => 'required|min:6',
                'role' => 'sometimes|string|in:user,admin'
            ]);

            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'role' => $request->role ?? 'user'
            ]);

            $token = $this->jwtService->generateToken($user->id, $user->role);
            $refreshToken = $this->jwtService->generateRefreshToken($user->id);

            return response()->json([
                'message' => 'User berhasil dibuat',
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                    'created_at' => $user->created_at,
                    'updated_at' => $user->updated_at
                ],
                'token' => $token,
                'refresh_token' => $refreshToken,
                'token_type' => 'Bearer',
                'expires_in' => env('JWT_EXPIRE', 3600)
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'error' => 'Gagal membuat user',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    // public function login(Request $request)
    // {
    //     try {
    //         $this->validate($request, [
    //             'email' => 'required|email',
    //             'password' => 'required'
    //         ]);

    //         $user = User::where('email', $request->email)->first();

    //         if ($user) {
    //             \Log::info('Login Debug', [
    //                 'input_password' => $request->password,
    //                 'db_password' => $user->password,
    //                 'hash_check' => Hash::check($request->password, $user->password),
    //                 'direct_check' => password_verify($request->password, $user->password)
    //             ]);
    //         }

    //         if($user && Hash::check($request->password, $user->password))
    //         {
    //             $token = $this->jwtService->generateToken($user->id, $user->role);
    //             $refreshToken = $this->jwtService->generateRefreshToken($user->id);
    //             return response()->json([
    //                 'message' => 'Login berhasil',
    //                 'user' => [
    //                     'id' => $user->id,
    //                     'name' => $user->name,
    //                     'email' => $user->email,
    //                     'role' => $user->role,
    //                 ],
    //                 'token' => $token,
    //                 'refresh_token' => $refreshToken,
    //                 'token_type' => 'Bearer',
    //                 'expires_in' => env('JWT_EXPIRE', 3600)
    //             ]);
    //         }

    //         return response()->json([
    //             'error' => 'Email atau password salah'
    //         ], 401);

    //     } catch (Exception $e) {
    //         return response()->json([
    //             'error' => 'Gagal Login',
    //             'message' => $e->getMessage()
    //         ], 500);
    //     }
    // }


    public function login(Request $request)
{
    try {
        $this->validate($request, [
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $user = User::where('email', $request->email)->first();

        // DEBUG: Simpan info debug untuk response
        $debugInfo = [];
        if ($user) {
            $debugInfo = [
                'user_found' => true,
                'user_id' => $user->id,
                'input_password' => $request->password,
                'db_password' => $user->password,
                'db_password_length' => strlen($user->password),
                'hash_check' => Hash::check($request->password, $user->password),
                'direct_check' => password_verify($request->password, $user->password),
                'password_is_123' => ($request->password === 'password123')
            ];
        } else {
            $debugInfo = ['user_found' => false];
        }

        if($user && Hash::check($request->password, $user->password))
        {
            $token = $this->jwtService->generateToken($user->id, $user->role);
            $refreshToken = $this->jwtService->generateRefreshToken($user->id);
            return response()->json([
                'message' => 'Login berhasil',
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                ],
                'token' => $token,
                'refresh_token' => $refreshToken,
                'token_type' => 'Bearer',
                'expires_in' => env('JWT_EXPIRE', 3600),
                'debug' => $debugInfo // TEMPORARY DEBUG
            ]);
        }

        return response()->json([
            'error' => 'Email atau password salah',
            'debug' => $debugInfo // TEMPORARY DEBUG
        ], 401);

    } catch (Exception $e) {
        return response()->json([
            'error' => 'Gagal Login',
            'message' => $e->getMessage(),
            'debug' => $debugInfo ?? []
        ], 500);
    }
}

    public function refresh(Request $request)
    {
        try {
            $this->validate($request, [
                'refresh_token' => 'required|string'
            ]);

            $newToken = $this->jwtService->refreshToken($request->refresh_token);

            if (!$newToken) {
                return response()->json([
                    'error' => 'Invalid refresh token',
                    'message' => 'Refresh token expired atau invalid'
                ], 401);
            }

            return response()->json([
                'message' => 'Token berhasil di-refresh',
                'token' => $newToken,
                'token_type' => 'Bearer',
                'expires_in' => env('JWT_EXPIRE', 3600)
            ]);
        } catch (Exception $e) {
            return response()->json([
                'error' => 'Gagal refresh token',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function profile(Request $request)
    {
        try {
            $userId = $request->attributes->get('user_id');
            $user = User::find($userId);

            if (!$user) {
                return response()->json([
                    'error' => 'User tidak ditemukan'
                ], 404);
            }

            return response()->json([
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                    'creeated_at' => $user->created_at,
                    'updated_at' => $user->updated_at
                ]
            ]);
        } catch (Exception $e) {
            return response()->json([
                'error' => 'Gagal mengambil profile',
                'message'
            ], 500);
        }
    }

    public function index()
    {
        try {
            $users = User::select('id', 'name', 'email', 'role', 'created_at', 'updated_at')->get();
            return response()->json([
                'users' => $users
            ]);
        } catch (Exception $e) {
            return response()->json([
                'error' => 'Gagal mengambil data users',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function show($id)
    {
        try {
            $user = User::select('id', 'name', 'email', 'role', 'created_at', 'updated_at')->find($id);

            if(!$user) {
                return response()->json([
                    'error' => 'User tidak ditemukan'
                ], 404);
            }

            return response()->json(['user' => $user]);
        } catch (Exception $e) {
            return response()->json([
                'error' => 'Gagal mengambil data user',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request, $id)
    {
        try {
            $user = User::find($id);

            if(!$user) {
                return response()->json([
                    'error' => 'User tidak ditemukan'
                ], 404);
            }

            $this->validate($request, [
                'name' => 'sometimes|string',
                'email' => 'sometimes|string|unique:users,email,'.$id,
                'password' => 'sometimes|min:6',
                'role' => 'sometimes|string|in:user,admin'
            ]);

            $user->update($request->all());

            return response()->json([
                'message' => 'User berhasil diupdate',
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                    'created_at' => $user->created_at,
                    'updated_at' => $user->updated_at
                ]
            ]);
        } catch (Exception $e) {
            return response()->json([
                'error' => 'Gagal update user',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id)
    {
        try {
            $user = User::find($id);

            if(!$user) {
                return response()->json([
                    'error' => 'User tidak ditemukan'
                ], 404);
            }

            $user->delete();

            return response()->json([
                'message' => 'User berhasil dihapus'
            ]);
        } catch (Exception $e) {
            return response()->json([
                'error' => 'Gagal Menghapus user',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
