# NEXT-2 H-1: Home + Navigation TC Generation
# Gold Standard: HOME-001~007 (7) + NAV-001~005 (5) = 12 TCs
$uri = "http://localhost:8088/api/v1/testcases/generate/file"

$prompt = "DemoApp 홈(대시보드) 페이지 및 네비게이션 TC 생성. [대시보드] Todo 통계: 전체/진행중/완료 카운트 표시. 최근 게시글 최신 3개 표시(제목+날짜). 게시글 클릭 시 상세(/board/{id})로 이동. 'Todo 시작하기' 버튼 /todo 이동. '게시판 가기' 버튼 /board 이동. Todo 0개일 때 통계 전부 0. 게시글 0건일 때 '아직 게시글이 없습니다.' 메시지. [네비게이션] 상단 네비바: Home/Todo/Board 탭. 현재 페이지 활성화 표시(bg-blue-50 text-blue-600). 로고(DemoApp) 클릭 시 Home(/)으로 이동. 하단 푸터 'DemoApp v1.0 - GENQ Test Target' 표시. localStorage 기반이므로 서버 에러 TC 불필요."

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
    "15",
    "--$boundary",
    "Content-Disposition: form-data; name=`"urls`"",
    "",
    "http://localhost:5174/",
    "--$boundary--"
) -join $LF

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyLines)

Write-Host "Starting H-1: Home + Nav experiment (1 URL)..."
$sw = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $response = Invoke-RestMethod -Uri $uri -Method POST -Body $bodyBytes -ContentType "multipart/form-data; boundary=$boundary" -TimeoutSec 300
    $sw.Stop()
    Write-Host "Time: $($sw.Elapsed.TotalSeconds)s"
    $response | ConvertTo-Json -Depth 10 | Out-File -FilePath "c:\Project\demo-app\experiments\home\exp_h1_result.json" -Encoding UTF8
    Write-Host "Done. Saved."
} catch {
    $sw.Stop()
    Write-Host "ERROR after $($sw.Elapsed.TotalSeconds)s: $_"
}
