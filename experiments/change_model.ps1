# Change TC_GENERATE model from gpt-5-nano(1) to gpt-4.1-mini(4)
$funcs = Invoke-RestMethod -Uri 'http://localhost:8088/api/v2/admin/functions' -Method GET
$tcGen = $funcs | Where-Object { $_.funcId -eq 'TC_GENERATE' }

Write-Host "Before: modelId=$($tcGen.modelId)"

# Update model to gpt-4.1-mini (ID=4)
$body = @{
    funcId = "TC_GENERATE"
    modelId = 4
} | ConvertTo-Json

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($body)
$response = Invoke-RestMethod -Uri "http://localhost:8088/api/v2/admin/functions/TC_GENERATE" -Method PUT -Body $bodyBytes -ContentType "application/json; charset=utf-8"
Write-Host "Update response: $response"

# Verify
$funcs2 = Invoke-RestMethod -Uri 'http://localhost:8088/api/v2/admin/functions' -Method GET
$tcGen2 = $funcs2 | Where-Object { $_.funcId -eq 'TC_GENERATE' }
Write-Host "After: modelId=$($tcGen2.modelId)"
