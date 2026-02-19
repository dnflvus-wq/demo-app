# C-2: Todo page TC generation WITH Clarify context
# Compare with Phase 3-2 baseline (81.0% coverage, 5% hallucination)
$uri = "http://localhost:8088/api/v1/testcases/generate/file"

$prompt = "DemoApp Todo management page test"

$clarifyContext = '[User Answers] Q1: Focus on empty title submission (shows error message). No network error testing needed (localStorage based app). No concurrent access scenarios. Q2: Title maxLength 50 chars (HTML attribute prevents input beyond 50). Empty title submission shows error. Complete/incomplete toggle with visual style changes (strikethrough, gray text). Q3: Single user type only, no admin distinction. [Additional Info] - Title is required (maxLength=50). Description is optional (can be empty). - Priority has exactly 3 options: high (red text), medium (yellow text, default), low (gray text). - Edit mode: clicking edit button loads existing todo data into form. Add button text changes to modify. Cancel button appears. Clicking cancel resets form (clears title/desc, priority back to medium) and exits edit mode (button back to add). - Delete shows confirm dialog with message. Confirming removes item and shows toast. Canceling keeps item. - Three filter tabs: All/Active/Completed. Current tab has active style (bg-white, text-blue-600, shadow). Filters work combined with search (AND logic). - Search input filters by title (case insensitive). When no results, shows empty message. - Search combined with filter: both conditions apply simultaneously. For example, searching while Active filter is on shows only active todos matching the keyword. - Completed todo visual: checkbox checked, title strikethrough (line-through) and gray text (text-gray-400), background changes (bg-gray-50). - Empty list state: when zero todos exist, shows encouragement message. - localStorage persistence: all data persists across page refresh. - Toast messages appear for add, edit, and delete operations with specific messages.'

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
    "http://localhost:5174/todo",
    "--$boundary",
    "Content-Disposition: form-data; name=`"clarifyContext`"",
    "Content-Type: text/plain; charset=utf-8",
    "",
    $clarifyContext,
    "--$boundary--"
) -join $LF

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyLines)

Write-Host "Starting C-2: Todo with Clarify experiment..."
$sw = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $response = Invoke-RestMethod -Uri $uri -Method POST -Body $bodyBytes -ContentType "multipart/form-data; boundary=$boundary" -TimeoutSec 300
    $sw.Stop()
    Write-Host "Time: $($sw.Elapsed.TotalSeconds)s"
    $response | ConvertTo-Json -Depth 10 | Out-File -FilePath "c:\Project\demo-app\experiments\clarify\exp_c2_result.json" -Encoding UTF8
    Write-Host "Done. Saved exp_c2_result.json"
} catch {
    $sw.Stop()
    Write-Host "ERROR after $($sw.Elapsed.TotalSeconds)s: $_"
}
