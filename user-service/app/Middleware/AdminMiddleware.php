<?php

namespace App\Middleware;

use App\Services\JwtService;
use Closure;

class AdminMiddleware
{
    protected $jwtService;

    public function __construct(JwtService $jwtService)
    {
        $this->jwtService = $jwtService;
    }

    public function handle($request, Closure $next)
    {
        $token = $request->header('Authorization');

        if (!$token) {
            return response()->json([
                'error' => 'Token required',
            ], 401);
        }

        if (preg_match('/Bearer\s+(.*)$/i', $token, $matches)) {
            $token = $matches[1];
        }

        $payload = $this->jwtService->validateToken($token);
        if (!$payload || $payload['role'] !== 'admin') {
            return response()->json([
                'error' => 'Admin access required',
                'message' => 'Hanya admin yang bisa akses endpoint ini'
            ], 403);
        }

        $request->attributes->add([
            'user_id' => $payload['sub'],
            'user_role' => $payload['role']
        ]);

        return $next($request);
    }
}
