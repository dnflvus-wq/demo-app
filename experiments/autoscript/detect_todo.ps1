# Auto Script: Detect elements on Todo page
$uri = "http://localhost:8088/api/v2/admin/auto-scripts/detect-elements"
$body = @{ url = "http://localhost:5174/todo" } | ConvertTo-Json

Write-Host "Detecting elements on Todo page..."
$sw = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $response = Invoke-RestMethod -Uri $uri -Method POST -Body $body -ContentType "application/json; charset=utf-8" -TimeoutSec 60
    $sw.Stop()
    Write-Host "Time: $($sw.Elapsed.TotalSeconds)s"
    Write-Host "Page Title: $($response.pageTitle)"
    Write-Host "Element count: $($response.elements.Count)"
    Write-Host "Summary: $($response.elementSummary)"
    Write-Host ""
    Write-Host "--- Elements ---"
    $i = 0
    foreach ($el in $response.elements) {
        $i++
        Write-Host "$i. [$($el.elementType)] tag=$($el.elementTag) id=$($el.elementId) name=$($el.elementName) text='$($el.elementText)'"
    }

    # Save full result (without thumbnail to keep it small)
    $response.thumbnail = "[REMOVED]"
    $response | ConvertTo-Json -Depth 10 | Out-File -FilePath "c:\Project\demo-app\experiments\autoscript\detect_todo_result.json" -Encoding UTF8
} catch {
    $sw.Stop()
    Write-Host "ERROR after $($sw.Elapsed.TotalSeconds)s: $_"
}
