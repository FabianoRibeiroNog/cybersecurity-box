param(
    [string]$Port = "COM3"
)

$ErrorActionPreference = "Stop"

Write-Host "[INFO] Performing MicroPython soft reset on $Port..."
& py -m mpremote connect $Port soft-reset

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Soft reset failed on $Port." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "[OK] Soft reset completed successfully."
