Write-Host "=== COMPLETE MICROSERVICES INTEGRATION TEST ===" -ForegroundColor Cyan

Write-Host "`n1. Testing Gateway..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/" -TimeoutSec 5
    Write-Host "✅ Gateway: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "❌ Gateway ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n2. Testing User Service Direct..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8001/" -TimeoutSec 5
    Write-Host "✅ User Service: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "❌ User Service ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n3. Testing Todo Service Direct..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8002/" -TimeoutSec 5
    Write-Host "✅ Todo Service: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "❌ Todo Service ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n4. Testing Gateway -> User Service..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/api/users" -TimeoutSec 5
    Write-Host "✅ Gateway->User: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "❌ Gateway->User ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n5. Testing Gateway -> Todo Service..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/api/todos" -TimeoutSec 5
    Write-Host "✅ Gateway->Todo: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "❌ Gateway->Todo ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n6. Testing Create User via Gateway..." -ForegroundColor Yellow
try {
    $body = @{
        name = "Integration Test User"
        email = "integration@test.com"
        password = "password123"
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "http://localhost:8000/api/auth/register" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 5
    Write-Host "✅ Create User: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "❌ Create User ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n7. Testing Create Todo via Gateway..." -ForegroundColor Yellow
try {
    $body = @{
        title = "Integration Test Todo"
        description = "Created via full integration test"
        user_id = 1
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "http://localhost:8000/api/todos" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 5
    Write-Host "✅ Create Todo: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "❌ Create Todo ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n8. Final Data Check..." -ForegroundColor Yellow
try {
    $users = Invoke-WebRequest -Uri "http://localhost:8000/api/users" -TimeoutSec 5
    $todos = Invoke-WebRequest -Uri "http://localhost:8000/api/todos" -TimeoutSec 5
    Write-Host "✅ Users Data: $($users.Content)" -ForegroundColor Green
    Write-Host "✅ Todos Data: $($todos.Content)" -ForegroundColor Green
} catch {
    Write-Host "❌ Data Check ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== INTEGRATION TEST COMPLETE ===" -ForegroundColor Cyan