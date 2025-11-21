# test-jwt-auth.ps1
# PowerShell Script untuk Testing JWT Authentication

$baseUrl = "http://localhost:8000"
$headers = @{
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

Write-Host "=== TESTING JWT AUTHENTICATION ===" -ForegroundColor Green
Write-Host "Base URL: $baseUrl" -ForegroundColor Yellow
Write-Host ""

# Generate random email
$random = Get-Random -Minimum 1000 -Maximum 9999
$testEmail = "jwtuser$random@example.com"
$testPassword = "password123"
$userId = $null
$authToken = $null
$refreshToken = $null

function Show-Response {
    param($Response, $Title)
    Write-Host "✅ $Title" -ForegroundColor Green
    Write-Host "   Response:" -ForegroundColor White
    $Response | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor White
    Write-Host ""
}

function Show-Error {
    param($ErrorRecord, $Title)
    Write-Host "❌ $Title" -ForegroundColor Red
    Write-Host "   Error: $($ErrorRecord.Exception.Message)" -ForegroundColor Red
    
    if ($ErrorRecord.Exception.Response) {
        $statusCode = $ErrorRecord.Exception.Response.StatusCode.value__
        Write-Host "   Status Code: $statusCode" -ForegroundColor Red
        
        try {
            $reader = New-Object System.IO.StreamReader($ErrorRecord.Exception.Response.GetResponseStream())
            $reader.BaseStream.Position = 0
            $errorBody = $reader.ReadToEnd()
            $reader.Close()
            Write-Host "   Error Body: $errorBody" -ForegroundColor Red
        }
        catch {
            Write-Host "   Could not read error response body" -ForegroundColor Red
        }
    }
    Write-Host ""
}

try {
    # 1. TEST REGISTER USER
    Write-Host "1. TEST REGISTER USER" -ForegroundColor Cyan
    $registerBody = @{
        name = "JWT User $random"
        email = $testEmail
        password = $testPassword
        role = "user"
    } | ConvertTo-Json

    Write-Host "Registering user: $testEmail" -ForegroundColor Gray
    
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method Post -Body $registerBody -Headers $headers
    
    $userId = $registerResponse.user.id
    $authToken = $registerResponse.token
    $refreshToken = $registerResponse.refresh_token
    $headers["Authorization"] = "Bearer $authToken"
    
    Show-Response -Response $registerResponse -Title "REGISTER SUCCESS"

    # 2. TEST LOGIN
    Write-Host "2. TEST LOGIN" -ForegroundColor Cyan
    $loginBody = @{
        email = $testEmail
        password = $testPassword
    } | ConvertTo-Json

    Write-Host "Logging in with: $testEmail" -ForegroundColor Gray
    
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method Post -Body $loginBody -Headers $headers
    
    # Update token dengan yang baru dari login
    $authToken = $loginResponse.token
    $refreshToken = $loginResponse.refresh_token
    $headers["Authorization"] = "Bearer $authToken"
    
    Show-Response -Response $loginResponse -Title "LOGIN SUCCESS"

    # 3. TEST GET PROFILE (PROTECTED ROUTE)
    Write-Host "3. TEST GET PROFILE (PROTECTED ROUTE)" -ForegroundColor Cyan
    Write-Host "Getting user profile with JWT token..." -ForegroundColor Gray
    
    $profileResponse = Invoke-RestMethod -Uri "$baseUrl/api/users/profile" -Method Get -Headers $headers
    
    Show-Response -Response $profileResponse -Title "PROFILE SUCCESS"

    # 4. TEST REFRESH TOKEN
    Write-Host "4. TEST REFRESH TOKEN" -ForegroundColor Cyan
    $refreshBody = @{
        refresh_token = $refreshToken
    } | ConvertTo-Json

    Write-Host "Refreshing token..." -ForegroundColor Gray
    
    $refreshResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/refresh" -Method Post -Body $refreshBody -Headers $headers
    
    $newToken = $refreshResponse.token
    $headers["Authorization"] = "Bearer $newToken"
    
    Show-Response -Response $refreshResponse -Title "REFRESH TOKEN SUCCESS"

    # 5. TEST GET ALL USERS (PROTECTED)
    Write-Host "5. TEST GET ALL USERS (PROTECTED)" -ForegroundColor Cyan
    Write-Host "Getting all users with new token..." -ForegroundColor Gray
    
    $usersResponse = Invoke-RestMethod -Uri "$baseUrl/api/users" -Method Get -Headers $headers
    
    Show-Response -Response $usersResponse -Title "GET ALL USERS SUCCESS"

    # 6. TEST GET SPECIFIC USER
    Write-Host "6. TEST GET SPECIFIC USER" -ForegroundColor Cyan
    Write-Host "Getting user ID: $userId" -ForegroundColor Gray
    
    $userResponse = Invoke-RestMethod -Uri "$baseUrl/api/users/$userId" -Method Get -Headers $headers
    
    Show-Response -Response $userResponse -Title "GET USER SUCCESS"

    # 7. TEST UPDATE USER
    Write-Host "7. TEST UPDATE USER" -ForegroundColor Cyan
    $updateBody = @{
        name = "Updated JWT User $random"
        email = $testEmail
    } | ConvertTo-Json

    Write-Host "Updating user..." -ForegroundColor Gray
    
    $updateResponse = Invoke-RestMethod -Uri "$baseUrl/api/users/$userId" -Method Put -Body $updateBody -Headers $headers
    
    Show-Response -Response $updateResponse -Title "UPDATE USER SUCCESS"

    # 8. TEST UNAUTHORIZED ACCESS (without token)
    Write-Host "8. TEST UNAUTHORIZED ACCESS" -ForegroundColor Cyan
    Write-Host "Testing access without token..." -ForegroundColor Gray
    
    try {
        $tempHeaders = $headers.Clone()
        $tempHeaders.Remove("Authorization")
        $unauthorizedResponse = Invoke-RestMethod -Uri "$baseUrl/api/users/profile" -Method Get -Headers $tempHeaders -ErrorAction Stop
        Write-Host "❌ UNEXPECTED: Access granted without token!" -ForegroundColor Red
    }
    catch {
        Write-Host "✅ UNAUTHORIZED ACCESS BLOCKED (Expected)" -ForegroundColor Green
        Write-Host "   Message: $($_.Exception.Message)" -ForegroundColor White
    }
    Write-Host ""

    # 9. TEST ADMIN ROLE (Create admin user)
    Write-Host "9. TEST ADMIN ROLE" -ForegroundColor Cyan
    $adminEmail = "adminuser$random@example.com"
    $adminBody = @{
        name = "Admin User $random"
        email = $adminEmail
        password = $testPassword
        role = "admin"
    } | ConvertTo-Json

    Write-Host "Creating admin user..." -ForegroundColor Gray
    
    $adminRegisterResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method Post -Body $adminBody -Headers $headers
    
    $adminToken = $adminRegisterResponse.token
    $adminHeaders = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
        "Authorization" = "Bearer $adminToken"
    }
    
    Show-Response -Response $adminRegisterResponse -Title "ADMIN USER CREATED"

    # 10. TEST DELETE USER
    Write-Host "10. TEST DELETE USER" -ForegroundColor Cyan
    Write-Host "Deleting test user ID: $userId" -ForegroundColor Gray
    
    $deleteResponse = Invoke-RestMethod -Uri "$baseUrl/api/users/$userId" -Method Delete -Headers $headers
    
    Show-Response -Response $deleteResponse -Title "DELETE USER SUCCESS"

    # 11. VERIFY USER DELETED
    Write-Host "11. VERIFY USER DELETED" -ForegroundColor Cyan
    Write-Host "Verifying user is deleted..." -ForegroundColor Gray
    
    try {
        $verifyResponse = Invoke-RestMethod -Uri "$baseUrl/api/users/$userId" -Method Get -Headers $headers -ErrorAction Stop
        Write-Host "❌ USER STILL EXISTS - DELETE FAILED" -ForegroundColor Red
    }
    catch {
        Write-Host "✅ USER SUCCESSFULLY DELETED" -ForegroundColor Green
        Write-Host "   Verification: User not found (expected)" -ForegroundColor White
    }

}
catch {
    Show-Error -ErrorRecord $_ -Title "TEST FAILED"
}
finally {
    Write-Host ""
    Write-Host "=== JWT AUTH TEST COMPLETED ===" -ForegroundColor Green
    
    # Cleanup
    if ($headers.ContainsKey("Authorization")) {
        $headers.Remove("Authorization")
    }
}

Write-Host ""
Write-Host "Script execution finished." -ForegroundColor Yellow