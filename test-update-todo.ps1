Write-Host "=== TEST PATCH TOGGLE ROUTE ===" -ForegroundColor Cyan

# Gunakan todo yang sudah ada (ID 2)
$testTodoId = 2

Write-Host "`n1. Get Current Todo State..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8002/api/todos/$testTodoId" -TimeoutSec 5
    $todo = $response.Content | ConvertFrom-Json
    Write-Host "✅ Current Todo:" -ForegroundColor Green
    Write-Host "   - ID: $($todo.id)" -ForegroundColor White
    Write-Host "   - Title: $($todo.title)" -ForegroundColor White
    Write-Host "   - Completed: $($todo.completed)" -ForegroundColor White
} catch {
    Write-Host "❌ Get Todo ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

Write-Host "`n2. Test PATCH Toggle via Todo Service Direct..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8002/api/todos/$testTodoId/toggle" -Method PATCH -TimeoutSec 5
    Write-Host "✅ PATCH Direct Response: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "❌ PATCH Direct ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n3. Test PATCH Toggle via Gateway..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/api/todos/$testTodoId/toggle" -Method PATCH -TimeoutSec 5
    Write-Host "✅ PATCH via Gateway: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "❌ PATCH via Gateway ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n4. Verify Todo After Toggle..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8002/api/todos/$testTodoId" -TimeoutSec 5
    $todoAfter = $response.Content | ConvertFrom-Json
    Write-Host "✅ Todo After Toggle:" -ForegroundColor Green
    Write-Host "   - Completed: $($todoAfter.completed)" -ForegroundColor White
    Write-Host "   - Status Changed: $($todo.completed -ne $todoAfter.completed)" -ForegroundColor White
} catch {
    Write-Host "❌ Verify After Toggle ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== PATCH TEST COMPLETE ===" -ForegroundColor Cyan