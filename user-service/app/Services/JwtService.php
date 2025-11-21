<?php

namespace App\Services;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Exception;

class JwtService
{
    private $secretKey;
    private $algorithm = 'HS256';

    public function __construct()
    {
        $this->secretKey = env('JWT_SECRET', 'your-super-secret-jwt-key-min-32-chars');
    }

    public function generateToken($userId, $role = 'user')
    {
        $issuedAt = time();
        $expire = $issuedAt + (env('JWT_EXPIRE', 3600));

        $payload =  [
            'iss' => 'user-service',
            'aud' => 'microservices-app',
            'iat' => $issuedAt,
            'exp' => $expire,
            'sub' => $userId,
            'role' => $role
        ];

        return JWT::encode($payload, $this->secretKey, $this->algorithm);
    }

    public function generateRefreshToken($userId)
    {
        $issuedAt = time();
        $expire = $issuedAt + (env('JWT_REFRESH_EXPIRE', 86400));

        $payload =  [
            'iss' => 'user-service',
            'aud' => 'microservices-app',
            'iat' => $issuedAt,
            'exp' => $expire,
            'sub' => $userId,
            'type' => 'refresh'
        ];

        return JWT::encode($payload, $this->secretKey, $this->algorithm);
    }

    public function validateToken($token)
    {
        try {
            $decoded = JWT::decode($token, new Key($this->secretKey, $this->algorithm));
            return (array) $decoded;
        } catch (Exception $e) {
            return null;
        }
    }

    public function refreshToken($refreshtoken)
    {
        $payload = $this->validateToken($refreshtoken);
        if (!$payload || !isset($payload['type']) || $payload['type'] !== 'refresh') {
            return null;
        }
        return $this->generateToken($payload['sub'], $payload['role'] ?? 'user');
    }
}
