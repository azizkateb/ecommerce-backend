# Generate JWT token by logging in
$baseUrl = "http://localhost:8081/api"

$headers = @{
    "Content-Type" = "application/json"
}

# First, let's try to login with the provided credentials
# We need to find a valid user. Let's first check if the user exists

Write-Host "Attempting to login user aziz@gmail.com..." -ForegroundColor Green

$loginJson = @"
{
  "email": "aziz@gmail.com",
  "password": "aziz123"
}
"@

Write-Host "Request:" -ForegroundColor Yellow
Write-Host $loginJson

$loginUrl = "$baseUrl/users/login"
try {
    $response = Invoke-RestMethod -Uri $loginUrl -Method Post -Headers $headers -Body $loginJson
    Write-Host "[SUCCESS] Login successful!" -ForegroundColor Green
    Write-Host "Token: $($response.token)" -ForegroundColor Yellow
    Write-Host "User: $($response.user | ConvertTo-Json)" -ForegroundColor Yellow
    
    $newToken = $response.token
    
    # Now test with the new token
    Write-Host "`n========== Testing Order API with new token ==========" -ForegroundColor Cyan
    
    $authHeaders = @{
        "Authorization" = "Bearer $newToken"
        "Content-Type" = "application/json"
    }
    
    Write-Host "`n[TEST] GET /api/orders" -ForegroundColor Green
    $ordersUrl = "$baseUrl/orders"
    $getResponse = Invoke-RestMethod -Uri $ordersUrl -Method Get -Headers $authHeaders
    Write-Host "[SUCCESS]" -ForegroundColor Green
    Write-Host "Response: $($getResponse | ConvertTo-Json)" -ForegroundColor Yellow
    
    Write-Host "`n[TEST] POST /api/orders" -ForegroundColor Green
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
    $postResponse = Invoke-RestMethod -Uri $ordersUrl -Method Post -Headers $authHeaders -Body $orderJson
    Write-Host "[SUCCESS]" -ForegroundColor Green
    Write-Host "Order created - ID: $($postResponse.id), Order Number: $($postResponse.orderNumber)" -ForegroundColor Yellow
    
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
