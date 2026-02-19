# J-4: Todo detailed (same as Phase 3-2 params) - Judge v2 high quality test
$uri = "http://localhost:8088/api/v1/testcases/generate/file"
$prompt = @"
DemoApp Todo 관리 페이지 기능 테스트.
[추가] 제목(필수, maxlength=50), 설명(선택), 우선순위(높음/중간/낮음 select).
[목록] 체크박스 토글(완료/미완료), 수정 버튼, 삭제 버튼(확인 다이얼로그).
[필터] 전체/진행중/완료 3개 버튼.
[검색] 제목 기준 실시간 필터링.
추가 성공 시 '추가되었습니다' 토스트, 삭제 시 '삭제되었습니다' 토스트.
빈 제목 추가 불가(필수 입력).
수정 시 기존 데이터 폼에 로드, 취소 시 원래 상태 복원.
localStorage 기반이므로 네트워크 오류 TC 불필요.
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
    "http://localhost:5174/todo",
    "--$boundary--"
) -join $LF

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyLines)

Write-Host "Starting J-4: Todo detailed (cnt=20, Judge v2)..."
$sw = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $response = Invoke-RestMethod -Uri $uri -Method POST -Body $bodyBytes -ContentType "multipart/form-data; boundary=$boundary" -TimeoutSec 300
    $sw.Stop()
    Write-Host "Time: $($sw.Elapsed.TotalSeconds)s"
    $response | ConvertTo-Json -Depth 10 | Out-File -FilePath "c:\Project\demo-app\experiments\judge\exp_j4_result.json" -Encoding UTF8
    Write-Host "qltyIndex=$($response.testCases.qltyIndex) trust=$($response.testCases.trust)"
    Write-Host "clarity=$($response.testCases.clarity) feasibility=$($response.testCases.feasibility) completeness=$($response.testCases.completeness)"
} catch {
    $sw.Stop()
    Write-Host "ERROR after $($sw.Elapsed.TotalSeconds)s: $_"
}
