# C-2 Step 1: Clarify questions for Todo page
$uri = "http://localhost:8088/api/v1/testcases/clarify?prompt=DemoApp%20Todo%20management%20page%20test"

Write-Host "Calling Clarify API for Todo..."
try {
    $response = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -TimeoutSec 60
    $response | ConvertTo-Json -Depth 10 | Out-File -FilePath "c:\Project\demo-app\experiments\clarify\clarify_todo.json" -Encoding UTF8
    Write-Host "Done. Saved clarify_todo.json"
} catch {
    Write-Host "ERROR: $_"
}
