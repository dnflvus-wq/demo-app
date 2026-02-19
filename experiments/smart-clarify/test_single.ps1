$uri = "http://localhost:8088/api/v1/testcases/clarify"
$bodyStr = "prompt=" + [System.Uri]::EscapeDataString("로그인 TC 생성해줘")
$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyStr)
$req = [System.Net.HttpWebRequest]::Create($uri)
$req.Method = "POST"
$req.ContentType = "application/x-www-form-urlencoded; charset=utf-8"
$req.ContentLength = $bodyBytes.Length
$s = $req.GetRequestStream()
$s.Write($bodyBytes, 0, $bodyBytes.Length)
$s.Close()
$resp = $req.GetResponse()
$r = New-Object System.IO.StreamReader($resp.GetResponseStream(), [System.Text.Encoding]::UTF8)
$text = $r.ReadToEnd()
$r.Close()
$resp.Close()
Write-Host "Done"
