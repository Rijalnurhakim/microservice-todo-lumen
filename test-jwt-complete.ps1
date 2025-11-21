# test-jwt-complete.ps1
# Complete JWT Authentication Test

$baseUrl = "http://localhost:8000"
$headers = @{
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

Write-Host "=== COMPLETE JWT AUTHENTICATION TEST ===" -ForegroundColor Green
Write-Host "Base URL: $baseUrl" -ForegroundColor Yellow
Write-Host ""

# Generate random email
$random = Get-Random -Minimum 1000 -Maximum 9999
$testEmail = "user$random@example.com"
$testPassword = "password123"  # Minimum 6 characters
$userId = $null
$authToken = $null
$refreshToken = $null

function Show-Success {
    param($Response, $Title)
    Write-Host "✅ $Title" -ForegroundColor Green
    if ($Response.token) {
        Write-Host "   Token: $($Response.token.Substring(0, 30))..." -ForegroundColor White
    }
    if ($Response.user) {
        Write-Host "   User: $($Response.user.name) (ID: $($Response.user.id))" -ForegroundColor White
    }
    Write-Host ""
}

function Show-Error {
    param($ErrorRecord, $Title)
    Write-Host "❌ $Title" -ForegroundColor Red
    Write-Host "   Error: $($ErrorRecord.Exception.Message)" -ForegroundColor Red
    
    if ($ErrorRecord.Exception.Response) {
        $statusCode = $ErrorRecord.Exception.Response.StatusCode.value__
        Write-Host "   Status Code: $statusCode" -ForegroundColor Red
    }
    Write-Host ""
}

try {
    # 1. TEST REGISTER
    Write-Host "1. TEST REGISTER" -ForegroundColor Cyan
    $registerBody = @{
        name = "Test User $random"
        email = $testEmail
        password = $testPassword
    } | ConvertTo-Json

    Write-Host "   Registering: $testEmail" -ForegroundColor Gray
    
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method Post -Body $registerBody -Headers $headers
    
    $userId = $registerResponse.user.id
    $authToken = $registerResponse.token
    $refreshToken = $registerResponse.refresh_token
    $headers["Authorization"] = "Bearer $authToken"
    
    Show-Success -Response $registerResponse -Title "REGISTER SUCCESS"

    # 2. TEST LOGIN
    Write-Host "2. TEST LOGIN" -ForegroundColor Cyan
    $loginBody = @{
        email = $testEmail
        password = $testPassword
    } | ConvertTo-Json

    Write-Host "   Logging in: $testEmail" -ForegroundColor Gray
    
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method Post -Body $loginBody -Headers $headers
    
    # Update dengan token baru dari login
    $authToken = $loginResponse.token
    $refreshToken = $loginResponse.refresh_token
    $headers["Authorization"] = "Bearer $authToken"
    
    Show-Success -Response $loginResponse -Title "LOGIN SUCCESS"

    # 3. TEST GET PROFILE (PROTECTED)
    Write-Host "3. TEST GET PROFILE" -ForegroundColor Cyan
    Write-Host "   Accessing protected route..." -ForegroundColor Gray
    
    $profileResponse = Invoke-RestMethod -Uri "$baseUrl/api/users/profile" -Method Get -Headers $headers
    
    Show-Success -Response $profileResponse -Title "PROFILE ACCESS SUCCESS"

    # 4. TEST REFRESH TOKEN
    Write-Host "4. TEST REFRESH TOKEN" -ForegroundColor Cyan
    Write-Host "   Refreshing token..." -ForegroundColor Gray
    
    $refreshBody = @{
        refresh_token = $refreshToken
    } | ConvertTo-Json
    
    $refreshResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/refresh" -Method Post -Body $refreshBody -Headers $headers
    
    $newToken = $refreshResponse.token
    $headers["Authorization"] = "Bearer $newToken"
    
    Show-Success -Response $refreshResponse -Title "TOKEN REFRESH SUCCESS"

    # 5. TEST GET ALL USERS
    Write-Host "5. TEST GET ALL USERS" -ForegroundColor Cyan
    Write-Host "   Getting all users..." -ForegroundColor Gray
    
    $usersResponse = Invoke-RestMethod -Uri "$baseUrl/api/users" -Method Get -Headers $headers
    
    Write-Host "✅ GET ALL USERS SUCCESS" -ForegroundColor Green
    Write-Host "   Total users: $(($usersResponse.users | Measure-Object).Count)" -ForegroundColor White
    Write-Host ""

    # 6. TEST GET SPECIFIC USER
    Write-Host "6. TEST GET SPECIFIC USER" -ForegroundColor Cyan
    Write-Host "   Getting user ID: $userId" -ForegroundColor Gray
    
    $userResponse = Invoke-RestMethod -Uri "$baseUrl/api/users/$userId" -Method Get -Headers $headers
    
    Show-Success -Response $userResponse -Title "GET USER SUCCESS"

    # 7. TEST UPDATE USER
    Write-Host "7. TEST UPDATE USER" -ForegroundColor Cyan
    $updatedName = "Updated User $random"
    $updateBody = @{
        name = $updatedName
        email = $testEmail
    } | ConvertTo-Json

    Write-Host "   Updating to: $updatedName" -ForegroundColor Gray
    
    $updateResponse = Invoke-RestMethod -Uri "$baseUrl/api/users/$userId" -Method Put -Body $updateBody -Headers $headers
    
    Show-Success -Response $updateResponse -Title "UPDATE USER SUCCESS"

    # 8. TEST DELETE USER
    Write-Host "8. TEST DELETE USER" -ForegroundColor Cyan
    Write-Host "   Deleting user ID: $userId" -ForegroundColor Gray
    
    $deleteResponse = Invoke-RestMethod -Uri "$baseUrl/api/users/$userId" -Method Delete -Headers $headers
    
    Write-Host "✅ DELETE USER SUCCESS" -ForegroundColor Green
    Write-Host "   Message: $($deleteResponse.message)" -ForegroundColor White
    Write-Host ""

    # 9. VERIFY DELETION
    Write-Host "9. VERIFY USER DELETED" -ForegroundColor Cyan
    Write-Host "   Verifying deletion..." -ForegroundColor Gray
    
    try {
        $verifyResponse = Invoke-RestMethod -Uri "$baseUrl/api/users/$userId" -Method Get -Headers $headers -ErrorAction Stop
        Write-Host "❌ USER STILL EXISTS" -ForegroundColor Red
    }
    catch {
        Write-Host "✅ USER SUCCESSFULLY DELETED" -ForegroundColor Green
        Write-Host "   Expected: User not found" -ForegroundColor White
    }

    Write-Host ""
    Write-Host "🎉 ALL TESTS COMPLETED SUCCESSFULLY!" -ForegroundColor Green

}
catch {
    Show-Error -ErrorRecord $_ -Title "TEST FAILED"
}
finally {
    # Cleanup
    if ($headers.ContainsKey("Authorization")) {
        $headers.Remove("Authorization")
    }
}

Write-Host ""
Write-Host "Script execution finished." -ForegroundColor Yellow