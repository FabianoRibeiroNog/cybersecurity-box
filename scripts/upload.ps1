param(
    [string]$Port = "COM3"
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir "..")
$firmwareDir = Join-Path $repoRoot "firmware\esp32"
$uploadOrder = @(
    "wifi_monitor.py",
    "time_sync.py",
    "main.py"
)

if (-not (Test-Path -LiteralPath $firmwareDir -PathType Container)) {
    Write-Host "[ERROR] Firmware directory not found: $firmwareDir" -ForegroundColor Red
    exit 1
}

foreach ($fileName in $uploadOrder) {
    $sourcePath = Join-Path $firmwareDir $fileName

    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
        Write-Host "[SKIP] $fileName not found in firmware/esp32."
        continue
    }

    Write-Host "[UPLOAD] $fileName -> /$fileName"
    & py -m mpremote connect $Port fs cp $sourcePath ":$fileName"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Upload failed for $fileName. Stopping." -ForegroundColor Red
        exit $LASTEXITCODE
    }

    Write-Host "[OK] Uploaded $fileName."
}

Write-Host "[UPLOAD] Performing soft reset after successful uploads..."
& py -m mpremote connect $Port soft-reset

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Soft reset failed after upload." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "[OK] Firmware upload completed and ESP32 soft reset succeeded."
