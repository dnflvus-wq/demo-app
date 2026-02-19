# Auto Script: Detect elements on all demo-app pages
$uri = "http://localhost:8088/api/v2/admin/auto-scripts/detect-elements"
$pages = @(
    @{Name="Board Write"; Url="http://localhost:5174/board/write"},
    @{Name="Board List"; Url="http://localhost:5174/board"},
    @{Name="Home"; Url="http://localhost:5174/"}
)

foreach ($p in $pages) {
    $body = @{ url = $p.Url } | ConvertTo-Json
    Write-Host "=== $($p.Name) ==="
    try {
        $response = Invoke-RestMethod -Uri $uri -Method POST -Body $body -ContentType "application/json; charset=utf-8" -TimeoutSec 60
        Write-Host "Elements: $($response.elements.Count) | Summary: $($response.elementSummary)"
        $i = 0
        foreach ($el in $response.elements) {
            $i++
            Write-Host "  $i. [$($el.elementType)] tag=$($el.elementTag) id=$($el.elementId) name=$($el.elementName)"
        }
        # Save result
        $response.thumbnail = "[REMOVED]"
        $safeName = $p.Name -replace ' ', '_'
        $response | ConvertTo-Json -Depth 10 | Out-File -FilePath "c:\Project\demo-app\experiments\autoscript\detect_${safeName}_result.json" -Encoding UTF8
    } catch {
        Write-Host "ERROR: $_"
    }
    Write-Host ""
}
