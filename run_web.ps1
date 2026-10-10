$ErrorActionPreference = 'Stop'

Push-Location $PSScriptRoot
try {
    Write-Host 'Open http://localhost:8080 in your regular Chrome window (not Incognito).'
    Write-Host 'Use the same Chrome profile each time to keep saved tasks.'
    & flutter run -d web-server --web-hostname localhost --web-port 8080
    $flutterExitCode = $LASTEXITCODE
} finally {
    Pop-Location
}
exit $flutterExitCode
