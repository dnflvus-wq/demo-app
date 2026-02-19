# Update ai_prompt_tb prompt_id=2 with tuned instructions
$uri = "http://localhost:8088/api/v2/admin/prompts/2"

$content = Get-Content -Path "c:\Project\demo-app\experiments\tuned_instructions.txt" -Raw -Encoding UTF8

# Escape for JSON: backslash, quotes, newlines
$escaped = $content -replace '\\', '\\' -replace '"', '\"' -replace "`r`n", '\n' -replace "`n", '\n' -replace "`r", '\n' -replace "`t", '\t'

$json = @"
{"content":"$escaped","description":"TC 전체 생성","useYn":"Y"}
"@

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($json)

$response = Invoke-RestMethod -Uri $uri -Method PUT -Body $bodyBytes -ContentType "application/json; charset=utf-8"
Write-Host "Response: $response"
Write-Host "Prompt updated successfully"
