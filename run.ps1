Param(
    [switch]$SkipBuild
)

Write-Host "[eCommerceWebsite] Starting local server with Jetty..."

if (-not (Get-Command mvn -ErrorAction SilentlyContinue)) {
    Write-Error "Maven (mvn) chưa được cài đặt hoặc không có trong PATH. Cài đặt Maven rồi chạy lại."
    exit 1
}

if (-not $SkipBuild) {
    Write-Host "[eCommerceWebsite] Building (skipTests)..."
    mvn -q -DskipTests=true clean package
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

$port = $env:PORT
if (-not $port) { $port = 8080 }

Write-Host "[eCommerceWebsite] Running on http://localhost:$port"
mvn -Djetty.http.port=$port jetty:run
