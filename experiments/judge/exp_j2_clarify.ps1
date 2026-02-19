# J-2: Board Write + Clarify (same as C-1) - Judge v2 test
$uri = "http://localhost:8088/api/v1/testcases/generate/file"
$prompt = "DemoApp board write page functional test"
$clarifyContext = '[User Answers] Q1: Focus on required field missing, max length exceeded, content minimum length violation. No network error testing needed (localStorage app). Q2: Include empty title/content, max title length 100, content minimum 10 chars boundary (9 chars fail, 10 chars pass), special characters. Q3: Single user type only, no admin distinction. [Additional Info] Edit mode exists at /board/write/{id} with pre-loaded data and button text changes to modify. Toast messages: registration success shows toast, edit success shows toast. Cancel button navigates back. Category select has 3 options. Secret post checkbox available. Character counter shows below content field. Page title differs between new and edit mode. Error messages clear when user starts typing in the field. Multiple validation errors can show simultaneously.'

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
    "--$boundary",
    "Content-Disposition: form-data; name=`"clarifyContext`"",
    "Content-Type: text/plain; charset=utf-8",
    "",
    $clarifyContext,
    "--$boundary--"
) -join $LF

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyLines)

Write-Host "Starting J-2: Board Write + Clarify (Judge v2)..."
$sw = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $response = Invoke-RestMethod -Uri $uri -Method POST -Body $bodyBytes -ContentType "multipart/form-data; boundary=$boundary" -TimeoutSec 300
    $sw.Stop()
    Write-Host "Time: $($sw.Elapsed.TotalSeconds)s"
    $response | ConvertTo-Json -Depth 10 | Out-File -FilePath "c:\Project\demo-app\experiments\judge\exp_j2_result.json" -Encoding UTF8
    Write-Host "Done. qltyIndex=$($response.testCases.qltyIndex) trust=$($response.testCases.trust)"
} catch {
    $sw.Stop()
    Write-Host "ERROR after $($sw.Elapsed.TotalSeconds)s: $_"
}
