# Phase 3-2: URL Parsing Improvement Test
# Same prompt as FINAL experiment, to compare parsing output difference
$uri = "http://localhost:8088/api/v1/testcases/generate/file"

$prompt = @"
DemoApp은 Todo 관리와 게시판 기능을 제공하는 웹 애플리케이션이다.

[Todo 페이지 기능 상세]
- 제목(필수, 최대 50자), 설명(선택), 우선순위(높음/보통/낮음) 입력 후 추가 버튼으로 등록
- 체크박스로 완료/미완료 토글 (완료 시 취소선+회색 스타일)
- 수정 버튼 클릭 시 폼에 기존값 로드, 변경 후 저장 가능. 취소 시 원래 값 복원.
- 삭제 시 확인 다이얼로그 표시 (확인/취소)
- 필터 3종: 전체(모든 항목), 진행중(미완료만), 완료(완료만) 탭 전환
- 검색: 제목 기준 키워드 검색 (검색 결과 있음/없음 각각 검증)
- 유효성: 빈 제목 제출 시 "제목을 입력해주세요" 에러 메시지
- 토스트 알림: 추가 시 "Todo가 추가되었습니다", 수정 시 "Todo가 수정되었습니다", 삭제 시 "Todo가 삭제되었습니다"
- localStorage 기반 데이터 저장 (서버 API 없음, 페이지네이션 없음)

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
    "20",
    "--$boundary",
    "Content-Disposition: form-data; name=`"urls`"",
    "",
    "http://localhost:5174/todo",
    "--$boundary--"
) -join $LF

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyLines)

Write-Host "Starting Phase 3-2 experiment (improved URL parsing)..."
$sw = [System.Diagnostics.Stopwatch]::StartNew()

$response = Invoke-RestMethod -Uri $uri -Method POST -Body $bodyBytes -ContentType "multipart/form-data; boundary=$boundary"

$sw.Stop()
Write-Host "Generation time: $($sw.Elapsed.TotalSeconds) seconds"

$response | ConvertTo-Json -Depth 10 | Out-File -FilePath "c:\Project\demo-app\experiments\exp4_parsing_result.json" -Encoding UTF8
Write-Host "Phase 3-2 experiment completed. Saved to exp4_parsing_result.json"
