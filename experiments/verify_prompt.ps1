$r = Invoke-RestMethod -Uri 'http://localhost:8088/api/v2/admin/prompts/2' -Method GET
$c = $r.content

Write-Host "Content length: $($c.Length)"

if ($c -match 'localStorage') { Write-Host 'OK: localStorage rule exists' } else { Write-Host 'FAIL: localStorage rule missing' }
if ($c -match '필수 커버 항목') { Write-Host 'OK: mandatory coverage section' } else { Write-Host 'FAIL: mandatory coverage missing' }
if ($c -match '역행 시나리오') { Write-Host 'OK: reverse flow section' } else { Write-Host 'FAIL: reverse flow missing' }
if ($c -match 'data-testid') { Write-Host 'OK: data-testid guidance' } else { Write-Host 'FAIL: data-testid missing' }
if ($c -match '필터/탭 전환') { Write-Host 'OK: filter/tab coverage' } else { Write-Host 'FAIL: filter coverage missing' }
if ($c -match '토스트/알림') { Write-Host 'OK: toast coverage' } else { Write-Host 'FAIL: toast coverage missing' }
if ($c -match '추측으로 기능을 만들어내지') { Write-Host 'OK: anti-hallucination rule' } else { Write-Host 'FAIL: anti-hallucination missing' }
