param(
    [string]$Port = "COM3",
    [string]$SecretsPath = (Join-Path $HOME ".cybersecurity-box\wifi_secrets.py")
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SecretsPath -PathType Leaf)) {
    Write-Host "[ERROR] Wi-Fi secrets file not found." -ForegroundColor Red
    Write-Host "[INFO] Create it outside the repository, then rerun this script."
    Write-Host "[INFO] Default location: `$HOME\.cybersecurity-box\wifi_secrets.py"
    exit 1
}

Write-Host "[UPLOAD] Uploading local Wi-Fi secrets to ESP32 on $Port..."
& py -m mpremote connect $Port fs cp $SecretsPath ":wifi_secrets.py"

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to upload Wi-Fi secrets to ESP32." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "[OK] Wi-Fi secrets uploaded to ESP32."
Write-Host "[INFO] Verifying wifi_secrets.py exists on ESP32..."
& py -m mpremote connect $Port exec "import os; os.stat('wifi_secrets.py')"

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Could not verify wifi_secrets.py on ESP32." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "[OK] wifi_secrets.py exists on ESP32."
