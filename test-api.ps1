# Test Order API Script
$token = "eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJheml6QGdtYWlsLmNvbSIsImlhdCI6MTc3NzMxNjMyMSwiZXhwIjoxNzc3NDAyNzIxfQ.GrM9qbUS3zc4bOnJlpp8PFowYrZYplSCg-bTflMtp5DODRP5GKGbSfE17KhwrpN4"
$baseUrl = "http://localhost:8081/api/orders"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Write-Host "`n========== Testing Order API Endpoints ==========" -ForegroundColor Cyan
Write-Host "User: aziz@gmail.com" -ForegroundColor Cyan

# Test 1: GET /api/orders
Write-Host "`n[TEST 1] GET /api/orders - Retrieve user orders" -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri $baseUrl -Method Get -Headers $headers
    Write-Host "[SUCCESS] Status 200" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Yellow
    Write-Host ($response | ConvertTo-Json -Depth 3)
} catch {
    Write-Host "[ERROR]" -ForegroundColor Red
    Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: POST /api/orders - Create basic order
Write-Host "`n[TEST 2] POST /api/orders - Create basic order" -ForegroundColor Green
$orderBody = @{
    items = @(
        @{
            product = @{ id = 1 }
            quantity = 2
            price = 29.99
        }
    )
} | ConvertTo-Json

Write-Host "Request Body:" -ForegroundColor Yellow
Write-Host $orderBody
try {
    $response = Invoke-RestMethod -Uri $baseUrl -Method Post -Headers $headers -Body $orderBody
    Write-Host "[SUCCESS] Status 201" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Yellow
    Write-Host ($response | ConvertTo-Json -Depth 3)
} catch {
    Write-Host "[ERROR]" -ForegroundColor Red
    Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        try {
            $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
            Write-Host "Response: $($streamReader.ReadToEnd())" -ForegroundColor Yellow
            $streamReader.Close()
        } catch { }
    }
}

# Test 3: POST /api/orders/checkout
Write-Host "`n[TEST 3] POST /api/orders/checkout - Create order with shipping" -ForegroundColor Green
$checkoutBody = @{
    items = @(
        @{
            product = @{ id = 1 }
            quantity = 1
            price = 29.99
        }
    )
    fullName = "Aziz Ahmed"
    address = "123 Main Street, City"
    phone = "+1-234-567-8900"
    paymentMethod = "CREDIT_CARD"
} | ConvertTo-Json

Write-Host "Request Body:" -ForegroundColor Yellow
Write-Host $checkoutBody
$checkoutUrl = "$baseUrl/checkout"
try {
    $response = Invoke-RestMethod -Uri $checkoutUrl -Method Post -Headers $headers -Body $checkoutBody
    Write-Host "[SUCCESS] Status 201" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Yellow
    Write-Host ($response | ConvertTo-Json -Depth 3)
} catch {
    Write-Host "[ERROR]" -ForegroundColor Red
    Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        try {
            $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
            Write-Host "Response: $($streamReader.ReadToEnd())" -ForegroundColor Yellow
            $streamReader.Close()
        } catch { }
    }
}

Write-Host "`n========== Tests Complete ==========" -ForegroundColor Cyan
