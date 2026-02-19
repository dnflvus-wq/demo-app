# Experiment 3-Tuned: Same as exp3 but with tuned instructions in DB
$uri = "http://localhost:8088/api/v1/testcases/generate/file"

$prompt = @"
DemoApp은 Todo 관리와 게시판 기능을 제공하는 웹 애플리케이션이다.

[Todo 페이지 기능 상세]
- 제목(필수, 최대 50자), 설명(선택), 우선순위(높음/보통/낮음) 입력 후 추가 버튼으로 등록
- 체크박스로 완료/미완료 토글 (완료 시 취소선+회색 스타일)
- 수정 버튼 클릭 시 폼에 기존값 로드, 변경 후 저장 가능
- 삭제 시 확인 다이얼로그 표시 (확인/취소)
- 필터: 전체/진행중/완료 탭 전환
- 검색: 제목 기준 키워드 검색
- 유효성: 빈 제목 제출 시 에러 메시지
- 토스트 알림: 추가/수정/삭제 시 각각 토스트 메시지
- localStorage 기반 데이터 저장

이 페이지에 대한 테스트 케이스를 생성해주세요.
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
    "15",
    "--$boundary",
    "Content-Disposition: form-data; name=`"urls`"",
    "",
    "http://localhost:5174/todo",
    "--$boundary--"
) -join $LF

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyLines)

Write-Host "Starting TC generation with TUNED instructions..."
$sw = [System.Diagnostics.Stopwatch]::StartNew()

$response = Invoke-RestMethod -Uri $uri -Method POST -Body $bodyBytes -ContentType "multipart/form-data; boundary=$boundary"

$sw.Stop()
Write-Host "Generation time: $($sw.Elapsed.TotalSeconds) seconds"

$response | ConvertTo-Json -Depth 10 | Out-File -FilePath "c:\Project\demo-app\experiments\exp3_tuned_result.json" -Encoding UTF8
Write-Host "Experiment 3-Tuned completed. Saved to exp3_tuned_result.json"

# Quick stats
$tc = $response.testcases
Write-Host "TC count: $($tc.Count)"
Write-Host "tcNm: $($response.tcNm)"
Write-Host "qltyIndex: $($response.qltyIndex)"
Write-Host "trust: $($response.trust)"
