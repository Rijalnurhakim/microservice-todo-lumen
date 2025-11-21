# 1. Register User
curl -X POST "http://localhost:8000/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "JWT Test User",
    "email": "jwttest@example.com",
    "password": "password123",
    "role": "user"
  }'

# 2. Login
curl -X POST "http://localhost:8000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "jwttest@example.com",
    "password": "password123"
  }'

# 3. Get Profile (Protected - butuh token)
# Copy token dari response login di atas
curl -X GET "http://localhost:8000/api/users/profile" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"

# 4. Refresh Token
curl -X POST "http://localhost:8000/api/auth/refresh" \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "YOUR_REFRESH_TOKEN_HERE"
  }'

# 5. Get All Users (Protected)
curl -X GET "http://localhost:8000/api/users" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"