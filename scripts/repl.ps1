param(
    [string]$Port = "COM3"
)

$ErrorActionPreference = "Stop"

Write-Host "[INFO] Opening MicroPython REPL on $Port. Press Ctrl+] to exit."
& py -m mpremote connect $Port repl
exit $LASTEXITCODE
