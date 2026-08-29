param(
    [string]$Port = "COM3"
)

$ErrorActionPreference = "Stop"

$infoCode = "import gc, machine, sys; v=sys.implementation.version; print('Implementation: %s %s.%s.%s' % (sys.implementation.name, v[0], v[1], v[2])); print('Platform: %s' % sys.platform); print('CPU frequency: %s Hz' % machine.freq()); print('Free heap: %s bytes' % gc.mem_free())"

Write-Host "[INFO] Reading ESP32 device information on $Port..."
& py -m mpremote connect $Port exec $infoCode

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to communicate with ESP32 on $Port." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "[OK] Device information read successfully."
