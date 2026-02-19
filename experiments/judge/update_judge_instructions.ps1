# Update TC_JUDGE instructions in DB (prompt_id=4)
$newInstructions = Get-Content -Path "c:\Project\demo-app\experiments\judge\judge_instructions_v2.txt" -Raw -Encoding UTF8

# Escape for SQL
$escaped = $newInstructions.Replace("'", "''").Replace("\", "\\")

$sql = "UPDATE ai_prompt_tb SET content = '$escaped' WHERE prompt_id = 4"

$mysqlPath = "C:\Program Files\MariaDB 11.4\bin\mysql.exe"
$result = & $mysqlPath --skip-ssl -h 61.75.21.224 -u genq -pzjawm12#`$ genqlab -e $sql 2>&1
Write-Host "Result: $result"

# Verify
$verify = & $mysqlPath --skip-ssl -h 61.75.21.224 -u genq -pzjawm12#`$ genqlab -e "SELECT LEFT(content, 100) as preview, RIGHT(content, 100) as tail FROM ai_prompt_tb WHERE prompt_id = 4" 2>&1
Write-Host "Verify: $verify"
