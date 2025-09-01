# Checks HTTP status for URLs from urls.txt and writes status.csv
$ErrorActionPreference = "Stop"
$in  = "$PSScriptRoot/urls.txt"
$out = "$PSScriptRoot/status.csv"

if (-not (Test-Path $in)) { throw "Create urls.txt with one URL per line" }

$client = [System.Net.Http.HttpClient]::new()
$client.Timeout = [TimeSpan]::FromSeconds(10)

"url,status,ms" | Out-File -Encoding UTF8 $out
Get-Content $in | ForEach-Object {
  $u = $_.Trim()
  if (-not $u) { return }
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  try {
    $resp = $client.GetAsync($u).Result
    $sw.Stop()
    "$u,$($resp.StatusCode),$([int]$sw.Elapsed.TotalMilliseconds)" | Add-Content -Path $out -Encoding UTF8
  } catch {
    $sw.Stop()
    "$u,ERROR,$([int]$sw.Elapsed.TotalMilliseconds)" | Add-Content -Path $out -Encoding UTF8
  }
}

$client.Dispose()
Write-Host "Done -> $out"
