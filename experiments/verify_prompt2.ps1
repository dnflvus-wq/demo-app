$r = Invoke-RestMethod -Uri 'http://localhost:8088/api/v2/admin/prompts/2' -Method GET
$c = $r.content

Write-Host "Content length: $($c.Length)"
Write-Host ""

# Use .Contains() instead of -match to avoid regex issues with Korean
$checks = @(
    @('localStorage', 'localStorage conditional rule'),
    @('data-testid', 'data-testid guidance'),
    @('UI State', 'UI State category'),
    @('Reverse Flow', 'Reverse Flow category'),
    @('WEB_UI_SPEC_JSON', 'URL spec tag reference'),
    @('tcNm', 'tcNm naming rule')
)

foreach ($check in $checks) {
    $keyword = $check[0]
    $label = $check[1]
    if ($c.Contains($keyword)) {
        Write-Host "OK: $label ($keyword)"
    } else {
        Write-Host "FAIL: $label ($keyword)"
    }
}

# Show last 200 chars to verify the end part is correct
Write-Host ""
Write-Host "=== Last 200 chars ==="
Write-Host $c.Substring($c.Length - 200)
