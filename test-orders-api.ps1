# Test Order API Script
$token = "eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJheml6QGdtYWlsLmNvbSIsImlhdCI6MTc3NzMxNjMyMSwiZXhwIjoxNzc3NDAyNzIxfQ.GrM9qbUS3zc4bOnJlpp8PFowYrZYplSCg-bTflMtp5DODRP5GKGbSfE17KhwrpN4"
$baseUrl = "http://localhost:8081/api/orders"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Write-Host "`n====================================================" -ForegroundColor Cyan
Write-Host "Testing Order API Endpoints" -ForegroundColor Cyan
Write-Host "User: aziz@gmail.com" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# Test 1: GET /api/orders - View user's orders
Write-Host "`n[TEST 1] GET /api/orders - Retrieve user's orders" -ForegroundColor Green
Write-Host "URL: $baseUrl" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri $baseUrl -Method Get -Headers $headers
    Write-Host "✓ Status: SUCCESS (200)" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Yellow
    if ($response -is [array]) {
        Write-Host "  Found $($response.Count) orders"
        $response | Format-List | Write-Host
    } else {
        Write-Host "  $($response | ConvertTo-Json -Depth 10)"
    }
} catch {
    Write-Host "✗ Status: ERROR" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: POST /api/orders - Create a basic order (without shipping details)
Write-Host "`n[TEST 2] POST /api/orders - Create a basic order" -ForegroundColor Green
$orderData = @{
    items = @(
        @{
            product = @{ id = 1 }
            quantity = 2
            price = 29.99
        }
    )
} | ConvertTo-Json

Write-Host "URL: $baseUrl" -ForegroundColor Yellow
Write-Host "Request Body:" -ForegroundColor Yellow
Write-Host $orderData
try {
    $response = Invoke-RestMethod -Uri $baseUrl -Method Post -Headers $headers -Body $orderData
    Write-Host "✓ Status: SUCCESS (201)" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Yellow
    Write-Host ($response | ConvertTo-Json -Depth 10)
    $orderId = $response.id
} catch {
    Write-Host "✗ Status: ERROR" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        Write-Host "Response Body: $($streamReader.ReadToEnd())" -ForegroundColor Yellow
    }
}

# Test 3: POST /api/orders/checkout - Create order with shipping and payment
Write-Host "`n[TEST 3] POST /api/orders/checkout - Create order with shipping & payment" -ForegroundColor Green
$checkoutData = @{
    items = @(
        @{
            product = @{ id = 1 }
            quantity = 1
            price = 29.99
        }
    )
    fullName = "Aziz Ahmed"
    address = "123 Main Street, City, Country"
    phone = "+1-234-567-8900"
    paymentMethod = "CREDIT_CARD"
} | ConvertTo-Json

$checkoutUrl = "$baseUrl/checkout"
Write-Host "URL: $checkoutUrl" -ForegroundColor Yellow
Write-Host "Request Body:" -ForegroundColor Yellow
Write-Host $checkoutData
try {
    $response = Invoke-RestMethod -Uri $checkoutUrl -Method Post -Headers $headers -Body $checkoutData
    Write-Host "✓ Status: SUCCESS (201)" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Yellow
    Write-Host ($response | ConvertTo-Json -Depth 10)
} catch {
    Write-Host "✗ Status: ERROR" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        Write-Host "Response Body: $($streamReader.ReadToEnd())" -ForegroundColor Yellow
    }
}

Write-Host "`n====================================================" -ForegroundColor Cyan
Write-Host "Tests Complete!" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
