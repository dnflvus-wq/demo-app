# NEXT-1 B-1: Board Write TC Generation (Detailed Prompt + URL)
# Gold Standard: WRITE-001~016 (16 TCs)
$uri = "http://localhost:8088/api/v1/testcases/generate/file"

$prompt = @"
DemoApp 게시판 글 작성 페이지 TC 생성.

[글 작성 페이지 기능 상세]
- 필드: 제목(필수, maxlength=100), 작성자(필수), 카테고리(select: 공지/자유/질문, 기본값 '자유'), 비밀글(checkbox), 내용(textarea, 필수, 10자 이상)
- 유효성 검사:
  * 제목 비어있으면 '제목을 입력해주세요' 에러 메시지 표시
  * 작성자 비어있으면 '작성자를 입력해주세요' 에러 메시지 표시
  * 내용 비어있으면 '내용을 입력해주세요' 에러 메시지 표시
  * 내용 9자 입력 시 '내용을 10자 이상 입력해주세요' 에러 메시지 표시
  * 내용 10자 입력 시 정상 등록 (경계값)
  * 모든 필드 비우고 등록 시 에러 3개 동시 표시
  * 에러 상태에서 해당 필드에 입력하면 해당 에러만 클리어
- 등록 성공 시 /board 목록으로 이동, 토스트 '글이 등록되었습니다'
- 수정 모드(/board/write/:id): 기존 값 로드, 버튼 '수정', 수정 성공 시 /board/{id} 상세로 이동, 토스트 '글이 수정되었습니다'
- 취소 버튼 → 이전 페이지로 이동
- 내용 아래 글자수 카운터 실시간 표시
- 비밀글 체크 시 목록에서 자물쇠 아이콘 표시
- 카테고리별 등록 확인: 공지(빨간 뱃지), 자유(파란 뱃지), 질문(초록 뱃지)
- localStorage 기반이므로 서버 에러/네트워크 에러 TC 불필요

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
    "http://localhost:5174/board/write",
    "--$boundary--"
) -join $LF

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyLines)

Write-Host "Starting B-1: Board Write experiment (detailed prompt + URL)..."
$sw = [System.Diagnostics.Stopwatch]::StartNew()

$response = Invoke-RestMethod -Uri $uri -Method POST -Body $bodyBytes -ContentType "multipart/form-data; boundary=$boundary"

$sw.Stop()
Write-Host "Generation time: $($sw.Elapsed.TotalSeconds) seconds"

$response | ConvertTo-Json -Depth 10 | Out-File -FilePath "c:\Project\demo-app\experiments\board\exp_b1_result.json" -Encoding UTF8
Write-Host "B-1 experiment completed. Saved to board/exp_b1_result.json"
