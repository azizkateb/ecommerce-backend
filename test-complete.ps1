# Register new user and test Order API
$baseUrl = "http://localhost:8081/api"

$headers = @{
    "Content-Type" = "application/json"
}

# Register a new test user
Write-Host "Registering a new test user..." -ForegroundColor Green

$registerJson = @"
{
  "email": "test@example.com",
  "password": "test123456",
  "name": "Test User"
}
"@

Write-Host "Request:" -ForegroundColor Yellow
Write-Host $registerJson

$registerUrl = "$baseUrl/users/register"
try {
    $registerResponse = Invoke-RestMethod -Uri $registerUrl -Method Post -Headers $headers -Body $registerJson
    Write-Host "[SUCCESS] User registered!" -ForegroundColor Green
    Write-Host "User ID: $($registerResponse.id)" -ForegroundColor Yellow
    Write-Host "Email: $($registerResponse.email)" -ForegroundColor Yellow
} catch {
    Write-Host "[NOTE] Registration error (user might already exist)" -ForegroundColor Yellow
    Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Now login
Write-Host "`nAttempting to login..." -ForegroundColor Green

$loginJson = @"
{
  "email": "test@example.com",
  "password": "test123456"
}
"@

Write-Host "Request:" -ForegroundColor Yellow
Write-Host $loginJson

$loginUrl = "$baseUrl/users/login"
try {
    $loginResponse = Invoke-RestMethod -Uri $loginUrl -Method Post -Headers $headers -Body $loginJson
    Write-Host "[SUCCESS] Login successful!" -ForegroundColor Green
    Write-Host "Token: $($loginResponse.token.Substring(0, 50))..." -ForegroundColor Yellow
    
    $authToken = $loginResponse.token
    
    # Test Order API endpoints with the new token
    Write-Host "`n========== Testing Order API with valid token ==========" -ForegroundColor Cyan
    
    $authHeaders = @{
        "Authorization" = "Bearer $authToken"
        "Content-Type" = "application/json"
    }
    
    # Test 1: GET /api/orders
    Write-Host "`n[TEST 1] GET /api/orders" -ForegroundColor Green
    $ordersUrl = "$baseUrl/orders"
    try {
        $getResponse = Invoke-RestMethod -Uri $ordersUrl -Method Get -Headers $authHeaders
        Write-Host "[SUCCESS] 200" -ForegroundColor Green
        Write-Host "Number of orders: $($getResponse.Count)" -ForegroundColor Yellow
    } catch {
        Write-Host "[ERROR]" -ForegroundColor Red
        Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test 2: POST /api/orders - Create basic order
    Write-Host "`n[TEST 2] POST /api/orders - Create basic order" -ForegroundColor Green
    $orderJson = @"
{
  "items": [
    {
      "product": {
        "id": 1
      },
      "quantity": 2,
      "price": 29.99
    }
  ]
}
"@
    Write-Host "Request Body:" -ForegroundColor Yellow
    Write-Host $orderJson
    try {
        $postResponse = Invoke-RestMethod -Uri $ordersUrl -Method Post -Headers $authHeaders -Body $orderJson
        Write-Host "[SUCCESS] 201" -ForegroundColor Green
        Write-Host "Order ID: $($postResponse.id)" -ForegroundColor Yellow
        Write-Host "Order Number: $($postResponse.orderNumber)" -ForegroundColor Yellow
        Write-Host "Total Price: $($postResponse.totalPrice)" -ForegroundColor Yellow
        Write-Host "Status: $($postResponse.status)" -ForegroundColor Yellow
    } catch {
        Write-Host "[ERROR]" -ForegroundColor Red
        Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            try {
                $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
                $content = $streamReader.ReadToEnd()
                Write-Host "Response: $content" -ForegroundColor Yellow
                $streamReader.Close()
            } catch { }
        }
    }
    
    # Test 3: POST /api/orders/checkout
    Write-Host "`n[TEST 3] POST /api/orders/checkout - Create order with shipping" -ForegroundColor Green
    $checkoutJson = @"
{
  "items": [
    {
      "product": {
        "id": 1
      },
      "quantity": 1,
      "price": 49.99
    }
  ],
  "fullName": "Test User",
  "address": "123 Test Street, Test City",
  "phone": "+1-555-123-4567",
  "paymentMethod": "CREDIT_CARD"
}
"@
    Write-Host "Request Body:" -ForegroundColor Yellow
    Write-Host $checkoutJson
    $checkoutUrl = "$baseUrl/orders/checkout"
    try {
        $checkoutResponse = Invoke-RestMethod -Uri $checkoutUrl -Method Post -Headers $authHeaders -Body $checkoutJson
        Write-Host "[SUCCESS] 201" -ForegroundColor Green
        Write-Host "Order ID: $($checkoutResponse.id)" -ForegroundColor Yellow
        Write-Host "Order Number: $($checkoutResponse.orderNumber)" -ForegroundColor Yellow
        Write-Host "Status: $($checkoutResponse.status)" -ForegroundColor Yellow
        Write-Host "Total Price: $($checkoutResponse.totalPrice)" -ForegroundColor Yellow
        Write-Host "Full Name: $($checkoutResponse.fullName)" -ForegroundColor Yellow
        Write-Host "Address: $($checkoutResponse.address)" -ForegroundColor Yellow
    } catch {
        Write-Host "[ERROR]" -ForegroundColor Red
        Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            try {
                $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
                $content = $streamReader.ReadToEnd()
                Write-Host "Response: $content" -ForegroundColor Yellow
                $streamReader.Close()
            } catch { }
        }
    }
    
} catch {
    Write-Host "[ERROR] Login failed" -ForegroundColor Red
    Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        try {
            $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
            $content = $streamReader.ReadToEnd()
            Write-Host "Response: $content" -ForegroundColor Yellow
            $streamReader.Close()
        } catch { }
    }
}

Write-Host "`n========== Test Summary ==========" -ForegroundColor Cyan
Write-Host "API testing complete!" -ForegroundColor Green
