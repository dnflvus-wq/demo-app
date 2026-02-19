# Get full TC_GENERATE config, change modelId, PUT back
$funcs = Invoke-RestMethod -Uri 'http://localhost:8088/api/v2/admin/functions' -Method GET
$tcGen = $funcs | Where-Object { $_.funcId -eq 'TC_GENERATE' }

Write-Host "Current config:"
$tcGen | ConvertTo-Json -Depth 3

# Modify modelId
$tcGen.modelId = 4

Write-Host "`nSending update with modelId=4..."
$json = $tcGen | ConvertTo-Json -Depth 3
$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($json)
$response = Invoke-RestMethod -Uri "http://localhost:8088/api/v2/admin/functions/TC_GENERATE" -Method PUT -Body $bodyBytes -ContentType "application/json; charset=utf-8"
Write-Host "Update response: $response"
