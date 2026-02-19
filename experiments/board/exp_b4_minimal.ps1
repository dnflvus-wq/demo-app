# NEXT-1 B-4: Board Write TC Generation (Minimal Prompt + URL)
# Control group: compare with B-1 (detailed prompt) to measure prompt detail effect
$uri = "http://localhost:8088/api/v1/testcases/generate/file"

$prompt = @"
DemoApp 게시판 글 작성 페이지의 기능 테스트
"@

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

Write-Host "Starting B-4: Board Write experiment (minimal prompt + URL)..."
$sw = [System.Diagnostics.Stopwatch]::StartNew()

$response = Invoke-RestMethod -Uri $uri -Method POST -Body $bodyBytes -ContentType "multipart/form-data; boundary=$boundary"

$sw.Stop()
Write-Host "Generation time: $($sw.Elapsed.TotalSeconds) seconds"

$response | ConvertTo-Json -Depth 10 | Out-File -FilePath "c:\Project\demo-app\experiments\board\exp_b4_result.json" -Encoding UTF8
Write-Host "B-4 experiment completed. Saved to board/exp_b4_result.json"
