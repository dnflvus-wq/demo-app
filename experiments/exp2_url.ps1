# Experiment 2: With URL (multipart form data)
$uri = "http://localhost:8088/api/v1/testcases/generate/file"

$boundary = [System.Guid]::NewGuid().ToString()
$LF = "`r`n"

$bodyLines = @(
    "--$boundary",
    "Content-Disposition: form-data; name=`"prompt`"",
    "Content-Type: text/plain; charset=utf-8",
    "",
    "DemoApp Todo 페이지 TC 생성",
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

$response = Invoke-RestMethod -Uri $uri -Method POST -Body $bodyBytes -ContentType "multipart/form-data; boundary=$boundary"
$response | ConvertTo-Json -Depth 10 | Out-File -FilePath "c:\Project\demo-app\experiments\exp2_result.json" -Encoding UTF8
Write-Host "Experiment 2 completed. Saved to exp2_result.json"
