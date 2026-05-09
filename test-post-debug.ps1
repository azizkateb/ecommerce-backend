# Detailed test to identify POST issue
$baseUrl = "http://localhost:8081/api"

# Register and login
$email = "posttest_$(Get-Random)@example.com"
$password = "test123456"

Write-Host "Registering user..." -ForegroundColor Green
$registerBody = "{`"email`": `"$email`", `"password`": `"$password`", `"name`": `"Test`"}"
$registerResp = Invoke-WebRequest -Uri "$baseUrl/users/register" -Method Post -Body $registerBody -ContentType "application/json" -UseBasicParsing

Write-Host "Logging in..." -ForegroundColor Green  
$loginBody = "{`"email`": `"$email`", `"password`": `"$password`"}"
$loginResp = Invoke-WebRequest -Uri "$baseUrl/users/login" -Method Post -Body $loginBody -ContentType "application/json" -UseBasicParsing
$token = ($loginResp.Content | ConvertFrom-Json).token

Write-Host "Token: $($token.Substring(0,30))..." -ForegroundColor Yellow

# Test GET with token
Write-Host "`n[TEST 1] GET /api/orders with token" -ForegroundColor Green
try {
    $getResp = Invoke-WebRequest `
        -Uri "$baseUrl/orders" `
        -Method Get `
        -Headers @{"Authorization" = "Bearer $token"; "Accept" = "*/*"} `
        -UseBasicParsing
    Write-Host "[SUCCESS] $($getResp.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

# Test POST with token - try different approaches
Write-Host "`n[TEST 2] POST /api/orders with token (Method 1: Invoke-RestMethod)" -ForegroundColor Green
$orderBody = '{"items":[{"product":{"id":1},"quantity":2,"price":29.99}]}'
try {
    $postResp = Invoke-RestMethod `
        -Uri "$baseUrl/orders" `
        -Method Post `
        -Headers @{"Authorization" = "Bearer $token"} `
        -Body $orderBody `
        -ContentType "application/json"
    Write-Host "[SUCCESS]" -ForegroundColor Green
    Write-Host "Order ID: $($postResp.id)" -ForegroundColor Yellow
} catch {
    Write-Host "[FAILED] Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Exception: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n[TEST 3] POST /api/orders with token (Method 2: Invoke-WebRequest)" -ForegroundColor Green
try {
    $postResp2 = Invoke-WebRequest `
        -Uri "$baseUrl/orders" `
        -Method Post `
        -Headers @{"Authorization" = "Bearer $token"; "Accept" = "*/*"} `
        -Body $orderBody `
        -ContentType "application/json" `
        -UseBasicParsing
    Write-Host "[SUCCESS] $($postResp2.StatusCode)" -ForegroundColor Green
    $content = $postResp2.Content | ConvertFrom-Json
    Write-Host "Order ID: $($content.id)" -ForegroundColor Yellow
} catch {
    Write-Host "[FAILED] Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}
