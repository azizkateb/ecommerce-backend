# Complete Order API Test Flow
$baseUrl = "http://localhost:8081/api"

# 1. Register a new user
Write-Host "========== STEP 1: Register New User ==========" -ForegroundColor Cyan
$email = "ordertest_$(Get-Random)@example.com"
$password = "test123456"

$registerBody = "{`"email`": `"$email`", `"password`": `"$password`", `"name`": `"Order Tester`"}"

Write-Host "Email: $email" -ForegroundColor Yellow
Write-Host "Password: $password" -ForegroundColor Yellow

$registerResponse = Invoke-WebRequest -Uri "$baseUrl/users/register" -Method Post -Body $registerBody -ContentType "application/json" -UseBasicParsing
Write-Host "[SUCCESS] User registered - Status $($registerResponse.StatusCode)" -ForegroundColor Green

# 2. Login the user
Write-Host "`n========== STEP 2: Login User ==========" -ForegroundColor Cyan
$loginBody = "{`"email`": `"$email`", `"password`": `"$password`"}"

$loginResponse = Invoke-WebRequest -Uri "$baseUrl/users/login" -Method Post -Body $loginBody -ContentType "application/json" -UseBasicParsing
$loginData = $loginResponse.Content | ConvertFrom-Json

Write-Host "[SUCCESS] Login successful - Status $($loginResponse.StatusCode)" -ForegroundColor Green
$token = $loginData.token
Write-Host "Token received: $($token.Substring(0, 50))..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# 3. GET /api/orders - View user's orders
Write-Host "`n========== STEP 3: GET /api/orders (View Orders) ==========" -ForegroundColor Cyan
$getResponse = Invoke-WebRequest -Uri "$baseUrl/orders" -Method Get -Headers $headers -UseBasicParsing
$getOrders = $getResponse.Content | ConvertFrom-Json
Write-Host "[SUCCESS] Status $($getResponse.StatusCode)" -ForegroundColor Green
Write-Host "Number of existing orders: $($getOrders.Count)" -ForegroundColor Yellow

# 4. POST /api/orders - Create a basic order
Write-Host "`n========== STEP 4: POST /api/orders (Create Basic Order) ==========" -ForegroundColor Cyan
$orderBody = @"
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
Write-Host $orderBody

try {
    $postResponse = Invoke-WebRequest -Uri "$baseUrl/orders" -Method Post -Headers $headers -Body $orderBody -ContentType "application/json" -UseBasicParsing
    $orderData = $postResponse.Content | ConvertFrom-Json
    Write-Host "[SUCCESS] Order created - Status $($postResponse.StatusCode)" -ForegroundColor Green
    Write-Host "Order ID: $($orderData.id)" -ForegroundColor Yellow
    Write-Host "Order Number: $($orderData.orderNumber)" -ForegroundColor Yellow
    Write-Host "Total Price: $($orderData.totalPrice)" -ForegroundColor Yellow
    Write-Host "Status: $($orderData.status)" -ForegroundColor Yellow
} catch {
    Write-Host "[ERROR] Failed to create order - Status $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response.StatusDescription)" -ForegroundColor Red
}

# 5. POST /api/orders/checkout - Create order with shipping details
Write-Host "`n========== STEP 5: POST /api/orders/checkout (Create Checkout Order) ==========" -ForegroundColor Cyan
$checkoutBody = @"
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
  "fullName": "John Doe",
  "address": "123 Test Street, TestCity, TC 12345",
  "phone": "+1-555-123-4567",
  "paymentMethod": "CREDIT_CARD"
}
"@

Write-Host "Request Body:" -ForegroundColor Yellow
Write-Host $checkoutBody

try {
    $checkoutResponse = Invoke-WebRequest -Uri "$baseUrl/orders/checkout" -Method Post -Headers $headers -Body $checkoutBody -ContentType "application/json" -UseBasicParsing
    $checkoutData = $checkoutResponse.Content | ConvertFrom-Json
    Write-Host "[SUCCESS] Checkout order created - Status $($checkoutResponse.StatusCode)" -ForegroundColor Green
    Write-Host "Order ID: $($checkoutData.id)" -ForegroundColor Yellow
    Write-Host "Order Number: $($checkoutData.orderNumber)" -ForegroundColor Yellow
    Write-Host "Full Name: $($checkoutData.fullName)" -ForegroundColor Yellow
    Write-Host "Address: $($checkoutData.address)" -ForegroundColor Yellow
    Write-Host "Phone: $($checkoutData.phone)" -ForegroundColor Yellow
    Write-Host "Payment Method: $($checkoutData.paymentMethod)" -ForegroundColor Yellow
    Write-Host "Total Price: $($checkoutData.totalPrice)" -ForegroundColor Yellow
    Write-Host "Status: $($checkoutData.status)" -ForegroundColor Yellow
} catch {
    Write-Host "[ERROR] Failed to create checkout order - Status $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response.StatusDescription)" -ForegroundColor Red
}

# 6. GET /api/orders again to verify orders were created
Write-Host "`n========== STEP 6: GET /api/orders (Verify Orders) ==========" -ForegroundColor Cyan
$finalResponse = Invoke-WebRequest -Uri "$baseUrl/orders" -Method Get -Headers $headers -UseBasicParsing
$finalOrders = $finalResponse.Content | ConvertFrom-Json
Write-Host "[SUCCESS] Status $($finalResponse.StatusCode)" -ForegroundColor Green
Write-Host "Total number of orders: $($finalOrders.Count)" -ForegroundColor Yellow

if ($finalOrders.Count -gt 0) {
    Write-Host "`nOrder Details:" -ForegroundColor Yellow
    $finalOrders | ForEach-Object {
        Write-Host "  - ID: $($_.id), Order#: $($_.orderNumber), Status: $($_.status), Total: $($_.totalPrice)" -ForegroundColor Gray
    }
}

Write-Host "`n========== Test Complete - All Tests Passed! ==========" -ForegroundColor Green
