# test-user.ps1 - FIXED VERSION
# PowerShell Script untuk Testing User Operations melalui API Gateway

$baseUrl = "http://localhost:8000"
$headers = @{
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

Write-Host "=== TESTING USER MICROSERVICE ===" -ForegroundColor Green
Write-Host "Base URL: $baseUrl" -ForegroundColor Yellow
Write-Host ""

# Generate random email untuk avoid duplicate
$random = Get-Random -Minimum 1000 -Maximum 9999
$testEmail = "testuser$random@example.com"
$testPassword = "password123"
$userId = $null
$authToken = $null

function Show-Error {
    param($ErrorRecord)
    
    Write-Host "❌ ERROR: $($ErrorRecord.Exception.Message)" -ForegroundColor Red
    
    if ($ErrorRecord.Exception.Response) {
        $statusCode = $ErrorRecord.Exception.Response.StatusCode.value__
        Write-Host "   Status Code: $statusCode" -ForegroundColor Red
        
        # Try to get error response body
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
}

try {
    # 1. TEST CREATE USER (REGISTER)
    Write-Host "1. TEST CREATE USER (REGISTER)" -ForegroundColor Cyan
    $createUserBody = @{
        name = "Test User $random"
        email = $testEmail
        password = $testPassword
    } | ConvertTo-Json

    Write-Host "Creating user: $testEmail" -ForegroundColor Gray
    Write-Host "Endpoint: $baseUrl/api/auth/register" -ForegroundColor Gray
    
    $createResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method Post -Body $createUserBody -Headers $headers
    
    $userId = $createResponse.user.id
    Write-Host "✅ CREATE USER SUCCESS" -ForegroundColor Green
    Write-Host "   User ID: $userId" -ForegroundColor White
    Write-Host "   Name: $($createResponse.user.name)" -ForegroundColor White
    Write-Host "   Email: $($createResponse.user.email)" -ForegroundColor White
    Write-Host ""

    # 2. TEST LOGIN
    Write-Host "2. TEST LOGIN" -ForegroundColor Cyan
    $loginBody = @{
        email = $testEmail
        password = $testPassword
    } | ConvertTo-Json

    Write-Host "Logging in with: $testEmail" -ForegroundColor Gray
    Write-Host "Endpoint: $baseUrl/api/auth/login" -ForegroundColor Gray
    
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method Post -Body $loginBody -Headers $headers
    
    $authToken = $loginResponse.token
    $headers["Authorization"] = "Bearer $authToken"
    
    Write-Host "✅ LOGIN SUCCESS" -ForegroundColor Green
    Write-Host "   Token: $($authToken)" -ForegroundColor White
    Write-Host ""

    # 3. TEST GET USER PROFILE
    Write-Host "3. TEST GET USER PROFILE" -ForegroundColor Cyan
    Write-Host "Getting user profile..." -ForegroundColor Gray
    Write-Host "Endpoint: $baseUrl/api/users/$userId" -ForegroundColor Gray
    
    $getUserResponse = Invoke-RestMethod -Uri "$baseUrl/api/users/$userId" -Method Get -Headers $headers
    
    Write-Host "✅ GET USER SUCCESS" -ForegroundColor Green
    Write-Host "   User ID: $($getUserResponse.user.id)" -ForegroundColor White
    Write-Host "   Name: $($getUserResponse.user.name)" -ForegroundColor White
    Write-Host "   Email: $($getUserResponse.user.email)" -ForegroundColor White
    Write-Host ""

    # 4. TEST UPDATE USER
    Write-Host "4. TEST UPDATE USER" -ForegroundColor Cyan
    $updatedName = "Updated User $random"
    $updateUserBody = @{
        name = $updatedName
        email = $testEmail
    } | ConvertTo-Json

    Write-Host "Updating user to: $updatedName" -ForegroundColor Gray
    Write-Host "Endpoint: $baseUrl/api/users/$userId" -ForegroundColor Gray
    
    $updateResponse = Invoke-RestMethod -Uri "$baseUrl/api/users/$userId" -Method Put -Body $updateUserBody -Headers $headers
    
    Write-Host "✅ UPDATE USER SUCCESS" -ForegroundColor Green
    Write-Host "   Updated Name: $($updateResponse.user.name)" -ForegroundColor White
    Write-Host ""

    # 5. TEST GET ALL USERS
    Write-Host "5. TEST GET ALL USERS" -ForegroundColor Cyan
    Write-Host "Getting all users..." -ForegroundColor Gray
    Write-Host "Endpoint: $baseUrl/api/users" -ForegroundColor Gray
    
    $getAllResponse = Invoke-RestMethod -Uri "$baseUrl/api/users" -Method Get -Headers $headers
    
    Write-Host "✅ GET ALL USERS SUCCESS" -ForegroundColor Green
    Write-Host "   Total Users: $(($getAllResponse.users | Measure-Object).Count)" -ForegroundColor White
    Write-Host ""

    # 6. TEST DELETE USER
    Write-Host "6. TEST DELETE USER" -ForegroundColor Cyan
    Write-Host "Deleting user ID: $userId" -ForegroundColor Gray
    Write-Host "Endpoint: $baseUrl/api/users/$userId" -ForegroundColor Gray
    
    $deleteResponse = Invoke-RestMethod -Uri "$baseUrl/api/users/$userId" -Method Delete -Headers $headers
    
    Write-Host "✅ DELETE USER SUCCESS" -ForegroundColor Green
    Write-Host "   Message: $($deleteResponse.message)" -ForegroundColor White
    Write-Host ""

    # 7. VERIFY USER DELETED
    Write-Host "7. VERIFY USER DELETED" -ForegroundColor Cyan
    Write-Host "Verifying user is deleted..." -ForegroundColor Gray
    Write-Host "Endpoint: $baseUrl/api/users/$userId" -ForegroundColor Gray
    
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
    Show-Error -ErrorRecord $_
}
finally {
    Write-Host ""
    Write-Host "=== TEST COMPLETED ===" -ForegroundColor Green
    
    # Cleanup headers
    if ($headers.ContainsKey("Authorization")) {
        $headers.Remove("Authorization")
    }
}

Write-Host ""
Write-Host "Script execution finished." -ForegroundColor Yellow