# J-1: Board Write baseline (same as B-4) - Judge v2 test
$uri = "http://localhost:8088/api/v1/testcases/generate/file"
$prompt = "DemoApp board write page functional test"
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
    "20",
    "--$boundary",
    "Content-Disposition: form-data; name=`"urls`"",
    "",
    "http://localhost:5174/board/write",
    "--$boundary--"
) -join $LF

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyLines)

Write-Host "Starting J-1: Board Write baseline (Judge v2)..."
$sw = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $response = Invoke-RestMethod -Uri $uri -Method POST -Body $bodyBytes -ContentType "multipart/form-data; boundary=$boundary" -TimeoutSec 300
    $sw.Stop()
    Write-Host "Time: $($sw.Elapsed.TotalSeconds)s"
    $response | ConvertTo-Json -Depth 10 | Out-File -FilePath "c:\Project\demo-app\experiments\judge\exp_j1_result.json" -Encoding UTF8
    Write-Host "Done. qltyIndex=$($response.testCases.qltyIndex) trust=$($response.testCases.trust)"
} catch {
    $sw.Stop()
    Write-Host "ERROR after $($sw.Elapsed.TotalSeconds)s: $_"
}
