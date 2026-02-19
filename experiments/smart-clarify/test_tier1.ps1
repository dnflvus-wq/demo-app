# Smart Clarify Tier 1 Tests (S-1 ~ S-5)
$uri = "http://localhost:8088/api/v1/testcases/clarify"

$tests = @(
    @{ name = "S-1"; prompt = "로그인 TC 생성해줘" },
    @{ name = "S-2"; prompt = "게시판 글쓰기 TC" },
    @{ name = "S-3"; prompt = "할일 관리 TC" },
    @{ name = "S-4"; prompt = "대시보드 TC" },
    @{ name = "S-5"; prompt = "회원가입 TC" }
)

foreach ($test in $tests) {
    Write-Host "`n========== $($test.name): $($test.prompt) ==========" -ForegroundColor Cyan
    try {
        $body = @{ prompt = $test.prompt }
        $response = Invoke-RestMethod -Uri $uri -Method POST -Body $body -ContentType "application/x-www-form-urlencoded; charset=utf-8"
        $json = $response | ConvertTo-Json -Depth 10
        $outFile = "c:\Project\demo-app\experiments\smart-clarify\$($test.name)_result.json"
        $json | Out-File -FilePath $outFile -Encoding UTF8
        Write-Host "Summary: $($response.summary)"
        Write-Host "Questions: $($response.questions.Count)"
        foreach ($q in $response.questions) {
            Write-Host "  Q($($q.questionType)): $($q.question)"
            foreach ($opt in $q.options) {
                Write-Host "    - $($opt.label)"
            }
        }
        Write-Host "RecommendedCounts: $($response.recommendedCounts -join ', ')"
    } catch {
        Write-Host "ERROR: $_" -ForegroundColor Red
    }
}
Write-Host "`n========== All Tier 1 tests complete ==========" -ForegroundColor Green
