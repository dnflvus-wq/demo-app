# Experiment 1: Basic prompt (no URL)
$uri = "http://localhost:8088/api/v1/testcases/generate"
$body = @{
    prompt = "DemoApp Todo 페이지 테스트 케이스 생성. Todo 앱은 할일 추가, 수정, 삭제, 완료 토글, 필터, 검색 기능을 제공한다."
    cnt = 10
}
$response = Invoke-RestMethod -Uri $uri -Method POST -Body $body -ContentType "application/x-www-form-urlencoded; charset=utf-8"
$response | ConvertTo-Json -Depth 10 | Out-File -FilePath "c:\Project\demo-app\experiments\exp1_result.json" -Encoding UTF8
Write-Host "Experiment 1 completed. Saved to exp1_result.json"
