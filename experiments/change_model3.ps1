# Change TC_GENERATE to gpt-5-mini (ID=2) - supports reasoning.effort
$funcs = Invoke-RestMethod -Uri 'http://localhost:8088/api/v2/admin/functions' -Method GET
$tcGen = $funcs | Where-Object { $_.funcId -eq 'TC_GENERATE' }

$tcGen.modelId = 2
Write-Host "Changing to gpt-5-mini (modelId=2)..."

$json = $tcGen | ConvertTo-Json -Depth 3
$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($json)
$response = Invoke-RestMethod -Uri "http://localhost:8088/api/v2/admin/functions/TC_GENERATE" -Method PUT -Body $bodyBytes -ContentType "application/json; charset=utf-8"
Write-Host "Update response: $response"
