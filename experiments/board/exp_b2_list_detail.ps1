# NEXT-1 B-2: Board List + Detail TC Generation (2 URLs)
# Gold Standard: LIST-001~010 (10 TCs) + DETAIL-001~009 (9 TCs) = 19 TCs
$uri = "http://localhost:8088/api/v1/testcases/generate/file"

$prompt = @"
DemoApp 게시판 목록 및 상세 페이지 TC 생성.

[목록 페이지 기능 상세]
- 테이블 형태 게시글 목록 (컬럼: 번호/분류/제목/작성자/작성일/조회)
- 최신순 정렬 (최신 글이 상단)
- 카테고리 뱃지 색상: 공지=빨간색, 자유=파란색, 질문=초록색
- 비밀글은 제목 앞에 자물쇠(Lock) 아이콘 표시
- 제목 클릭 → 상세 페이지(/board/{id})로 이동
- '글쓰기' 버튼 → 글 작성 페이지(/board/write)로 이동
- 페이지네이션: 5개씩 표시, 6개 이상이면 2페이지 생김
- 이전/다음 버튼: 첫 페이지에서 이전 비활성화, 마지막 페이지에서 다음 비활성화
- 게시글 0건이면 '게시글이 없습니다.' 메시지

[상세 페이지 기능 상세]
- 제목/작성자/작성일/조회수/내용 표시
- 페이지 진입 시 조회수 +1 자동 증가
- 카테고리에 맞는 뱃지 라벨 표시
- 비밀글이면 '비밀글' 텍스트 + 자물쇠 아이콘
- 수정 버튼 → /board/write/{id} 수정 페이지로 이동
- 삭제 버튼 → '정말 삭제하시겠습니까?' 확인 다이얼로그 → 확인 시 /board 목록 이동 + 토스트 '글이 삭제되었습니다'
- 삭제 취소 시 상세 페이지 유지
- '목록으로' 버튼 → /board 목록 페이지로 이동
- 존재하지 않는 글 ID 접속 시 /board 목록으로 자동 리다이렉트

게시글 6개 이상 존재하는 상태에서 테스트.
localStorage 기반이므로 서버 에러/네트워크 에러 TC 불필요.

이 페이지들에 대한 테스트 케이스를 생성해주세요.
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
    "http://localhost:5174/board",
    "--$boundary",
    "Content-Disposition: form-data; name=`"urls`"",
    "",
    "http://localhost:5174/board/1",
    "--$boundary--"
) -join $LF

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyLines)

Write-Host "Starting B-2: Board List + Detail experiment (2 URLs)..."
$sw = [System.Diagnostics.Stopwatch]::StartNew()

$response = Invoke-RestMethod -Uri $uri -Method POST -Body $bodyBytes -ContentType "multipart/form-data; boundary=$boundary"

$sw.Stop()
Write-Host "Generation time: $($sw.Elapsed.TotalSeconds) seconds"

$response | ConvertTo-Json -Depth 10 | Out-File -FilePath "c:\Project\demo-app\experiments\board\exp_b2_result.json" -Encoding UTF8
Write-Host "B-2 experiment completed. Saved to board/exp_b2_result.json"
