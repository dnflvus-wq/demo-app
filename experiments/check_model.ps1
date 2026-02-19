$funcs = Invoke-RestMethod -Uri 'http://localhost:8088/api/v2/admin/functions' -Method GET
$tcGen = $funcs | Where-Object { $_.funcId -eq 'TC_GENERATE' }
Write-Host "=== TC_GENERATE Config ==="
Write-Host "funcId: $($tcGen.funcId)"
Write-Host "modelId: $($tcGen.modelId)"
Write-Host "modelName: $($tcGen.modelName)"
Write-Host "instructionId: $($tcGen.instructionId)"
Write-Host "schemaId: $($tcGen.schemaId)"
Write-Host ""

$models = Invoke-RestMethod -Uri 'http://localhost:8088/api/v2/admin/models' -Method GET
Write-Host "=== Available Models ==="
foreach ($m in $models) {
    Write-Host "ID=$($m.modelId) | $($m.modelName) | $($m.provider) | $($m.useYn)"
}
