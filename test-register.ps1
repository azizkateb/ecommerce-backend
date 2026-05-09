# Simple curl-based test
$baseUrl = "http://localhost:8081/api"

Write-Host "Testing registration endpoint..." -ForegroundColor Green
$email = "curlusertest_$(Get-Random)@example.com"
$body = "{`"email`": `"$email`", `"password`": `"test123456`", `"name`": `"Test User`"}"

Write-Host "Payload: $body"

$response = Invoke-WebRequest -Uri "$baseUrl/users/register" -Method Post -Body $body -ContentType "application/json" -UseBasicParsing

Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
Write-Host "Response:" -ForegroundColor Yellow
$response.Content | ConvertFrom-Json | ConvertTo-Json
