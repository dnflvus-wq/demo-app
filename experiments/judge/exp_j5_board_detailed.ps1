# J-5: Board Write detailed (similar to B-1) - Judge v2 with detailed prompt
$uri = "http://localhost:8088/api/v1/testcases/generate/file"
$prompt = @"
DemoApp 게시판 글 작성 페이지 TC 생성.
필드: 제목(필수, maxlength=100), 작성자(필수), 카테고리(select: 공지/자유/질문),
비밀글(checkbox), 내용(textarea, 필수, 10자 이상).
유효성: 제목 비어있으면 '제목을 입력해주세요', 작성자 비어있으면 '작성자를 입력해주세요',
내용 비어있으면 '내용을 입력해주세요', 내용 9자이면 '내용을 10자 이상 입력해주세요'.
등록 성공 시 '글이 등록되었습니다' 토스트.
취소 버튼으로 이전 페이지 이동.
localStorage 기반이므로 네트워크 에러 TC 불필요.
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
    "http://localhost:5174/board/write",
    "--$boundary--"
) -join $LF

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyLines)

Write-Host "Starting J-5: Board Write detailed (cnt=15, Judge v2)..."
$sw = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $response = Invoke-RestMethod -Uri $uri -Method POST -Body $bodyBytes -ContentType "multipart/form-data; boundary=$boundary" -TimeoutSec 300
    $sw.Stop()
    Write-Host "Time: $($sw.Elapsed.TotalSeconds)s"
    $response | ConvertTo-Json -Depth 10 | Out-File -FilePath "c:\Project\demo-app\experiments\judge\exp_j5_result.json" -Encoding UTF8
    Write-Host "qltyIndex=$($response.testCases.qltyIndex) trust=$($response.testCases.trust)"
    Write-Host "clarity=$($response.testCases.clarity) feasibility=$($response.testCases.feasibility) completeness=$($response.testCases.completeness)"
} catch {
    $sw.Stop()
    Write-Host "ERROR after $($sw.Elapsed.TotalSeconds)s: $_"
}
