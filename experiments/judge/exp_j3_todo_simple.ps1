# J-3: Simple Todo test with Judge v2 (no Clarify, minimal prompt)
$uri = "http://localhost:8088/api/v1/testcases/generate/file"
$prompt = "DemoApp Todo page functional test"
$boundary = [System.Guid]::NewGuid().ToString()
$LF = "`r`n"

$bodyLines = @(
    "--$boundary",
    "Content-Disposition: form-data; name=`"prompt`"",
    "Content-Type: text/plain; charset=utf-8",
    "",
    $prompt,
    "--$boundary",
    "Content-Disposition: form-data; name=`"cnt`"",
    "",
    "10",
    "--$boundary",
    "Content-Disposition: form-data; name=`"urls`"",
    "",
    "http://localhost:5174/todo",
    "--$boundary--"
) -join $LF

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyLines)

Write-Host "Starting J-3: Todo simple (cnt=10, Judge v2)..."
$sw = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $response = Invoke-RestMethod -Uri $uri -Method POST -Body $bodyBytes -ContentType "multipart/form-data; boundary=$boundary" -TimeoutSec 300
    $sw.Stop()
    Write-Host "Time: $($sw.Elapsed.TotalSeconds)s"
    $response | ConvertTo-Json -Depth 10 | Out-File -FilePath "c:\Project\demo-app\experiments\judge\exp_j3_result.json" -Encoding UTF8
    Write-Host "qltyIndex=$($response.testCases.qltyIndex) trust=$($response.testCases.trust)"
    Write-Host "clarity=$($response.testCases.clarity) feasibility=$($response.testCases.feasibility) completeness=$($response.testCases.completeness)"
} catch {
    $sw.Stop()
    Write-Host "ERROR after $($sw.Elapsed.TotalSeconds)s: $_"
}
