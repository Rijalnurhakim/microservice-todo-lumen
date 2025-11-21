<?php

namespace App\Middleware;

use Closure;
use App\Services\JwtService;

class JwtMiddleware
{
    protected $jwtService;

    public function __construct(JwtService $jwtService)
    {
        $this->jwtService = $jwtService;
    }

    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next, $role = null)
    {
        $token = $request->header('Authorization');

        if (!$token) {
            return response()->json([
                'error' => 'Token tidak provided',
                'message' => 'Authorization header required'
            ], 401);
        }

        if (preg_match('/Bearer\s+(.*)$/i', $token, $matches)) {
            $token = $matches[1];
        }

        $payload = $this->jwtService->validateToken($token);

        if (!$payload) {
            return response()->json([
                'error' => 'Token invalid',
                'message' => 'Token expired atau invalid'
            ], 401);
        }

        if ($role && $payload['role'] !== $role) {
            return response()->json([
                'error' => 'Unathorized',
                'message' => 'Insufficient permissions'
            ], 403);
        }

        $request->attributes->add([
            'user_id' => $payload['sub'],
            'user_role' => $payload['role']
        ]);

        return $next($request);
    }
}
