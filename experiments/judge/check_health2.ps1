try {
    $r = Invoke-RestMethod -Uri 'http://localhost:8088/api/v1/testcase?page=0&size=1' -TimeoutSec 10
    Write-Host "Backend OK. TC count: $($r.totalElements)"
} catch {
    Write-Host "ERROR: $_"
}
