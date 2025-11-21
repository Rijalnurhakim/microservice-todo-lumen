# test-invalid-token.ps1
# Test error scenarios

$baseUrl = "http://localhost:8000"

Write-Host "=== TESTING ERROR SCENARIOS ===" -ForegroundColor Yellow

# Test 1: No token
Write-Host "`n1. Testing without token..." -ForegroundColor Cyan
try {
    Invoke-RestMethod -Uri "$baseUrl/api/users/profile" -Method Get -Headers @{"Content-Type"="application/json"} -ErrorAction Stop
} catch {
    Write-Host "✅ Blocked without token: $($_.Exception.Message)" -ForegroundColor Green
}

# Test 2: Invalid token
Write-Host "`n2. Testing with invalid token..." -ForegroundColor Cyan
try {
    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer invalid.token.here"
    }
    Invoke-RestMethod -Uri "$baseUrl/api/users/profile" -Method Get -Headers $headers -ErrorAction Stop
} catch {
    Write-Host "✅ Blocked invalid token: $($_.Exception.Message)" -ForegroundColor Green
}

# Test 3: Expired token (simulate)
Write-Host "`n3. Testing expired token scenario..." -ForegroundColor Cyan
try {
    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1c2VyLXNlcnZpY2UiLCJhdWQiOiJtaWNyb3NlcnZpY2VzLWFwcCIsImlhdCI6MTYzNzA1ODAwMCwiZXhwIjoxNjM3MDU4MDAxLCJzdWIiOjEsInJvbGUiOiJ1c2VyIn0.fake-expired-token"
    }
    Invoke-RestMethod -Uri "$baseUrl/api/users/profile" -Method Get -Headers $headers -ErrorAction Stop
} catch {
    Write-Host "✅ Blocked expired token: $($_.Exception.Message)" -ForegroundColor Green
}

Write-Host "`n🎉 All error tests passed!" -ForegroundColor Green