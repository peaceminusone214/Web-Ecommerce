Param(
    [Alias('port')]
    [Nullable[int]]$Port
)

Write-Host "[eCommerceWebsite] Starting executable JAR..."

# Support --port and --port=VALUE from raw args as well
for ($i = 0; $i -lt $args.Length; $i++) {
    if ($args[$i] -eq '--port' -and $i + 1 -lt $args.Length) {
        $Port = [int]$args[$i + 1]
    } elseif ($args[$i] -like '--port=*') {
        $Port = [int]($args[$i].Split('=')[1])
    }
}

if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    Write-Error "Java khong co trong PATH. Cai dat JDK/JRE va thu lai."
    exit 1
}

# Pick latest exec jar in target; fallback to default name
$jar = $null
if (Test-Path 'target') {
    $candidate = Get-ChildItem -Path 'target' -Filter '*-exec.jar' -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if ($candidate) { $jar = $candidate.FullName }
}
if (-not $jar) { $jar = Join-Path (Get-Location) 'target\eCommerceWebsite-1.0-SNAPSHOT-exec.jar' }

if (-not (Test-Path $jar)) {
    Write-Error "Khong tim thay JAR tu chay: $jar`nHay build truoc bang: mvn -DskipTests=true clean package"
    exit 1
}

$portToUse = if ($Port) { $Port } elseif ($env:PORT) { [int]$env:PORT } else { 8080 }

Write-Host "[eCommerceWebsite] Running on http://localhost:$portToUse"
Write-Host "[eCommerceWebsite] JAR: $jar"

& java -Dport=$portToUse -jar $jar
exit $LASTEXITCODE

