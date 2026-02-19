$prompt = 'DemoApp board write page test'
$encoded = [System.Uri]::EscapeDataString($prompt)
$uri = 'http://localhost:8088/api/v1/testcases/clarify?prompt=' + $encoded

Write-Host 'Calling Clarify API...'
try {
    $response = Invoke-RestMethod -Uri $uri -Method POST -TimeoutSec 120
    $json = $response | ConvertTo-Json -Depth 10
    $json | Out-File -FilePath 'c:\Project\demo-app\experiments\clarify\clarify_board_write.json' -Encoding UTF8
    Write-Host 'Done.'
    Write-Host $json
} catch {
    Write-Host ('ERROR: ' + $_.Exception.Message)
}
