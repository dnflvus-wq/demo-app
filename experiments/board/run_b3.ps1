# B-3: Board All Pages (3 URLs combined) - simplified version
$uri = "http://localhost:8088/api/v1/testcases/generate/file"

$prompt = "DemoApp 게시판 전체 기능 TC 생성. (글 작성 + 목록 + 상세) [글 작성] 필드: 제목(필수, maxlength=100), 작성자(필수), 카테고리(select: 공지/자유/질문), 비밀글(checkbox), 내용(textarea, 필수, 10자 이상). 유효성: 제목/작성자/내용 비면 각각 에러. 내용 9자 에러, 10자 통과. 등록 토스트 '글이 등록되었습니다', 수정 토스트 '글이 수정되었습니다'. 취소 버튼 이전 페이지 이동. [목록] 카테고리 뱃지(공지=빨강, 자유=파랑, 질문=초록), 비밀글 자물쇠 아이콘. 페이지네이션 5개/페이지, 6개 이상이면 2페이지. 글쓰기 버튼 작성 페이지, 제목 클릭 상세 페이지. [상세] 조회수 진입 시 +1, 카테고리 뱃지, 비밀글 라벨. 수정 버튼 수정 페이지, 삭제(확인 다이얼로그) 목록+토스트 '글이 삭제되었습니다'. 목록으로 버튼 목록 페이지. localStorage 기반이므로 서버 에러/네트워크 에러 TC 불필요. 게시글 6개 이상 존재하는 상태에서 테스트."

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

Write-Host "Starting B-3: Board All Pages (3 URLs)..."
$sw = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $response = Invoke-RestMethod -Uri $uri -Method POST -Body $bodyBytes -ContentType "multipart/form-data; boundary=$boundary" -TimeoutSec 600
    $sw.Stop()
    Write-Host "Time: $($sw.Elapsed.TotalSeconds)s"
    $response | ConvertTo-Json -Depth 10 | Out-File -FilePath "c:\Project\demo-app\experiments\board\exp_b3_result.json" -Encoding UTF8
    Write-Host "Done. Saved."
} catch {
    $sw.Stop()
    Write-Host "ERROR after $($sw.Elapsed.TotalSeconds)s: $_"
}
