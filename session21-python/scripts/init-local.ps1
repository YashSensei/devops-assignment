$ErrorActionPreference = 'Stop'
$target = Join-Path $PSScriptRoot '..\.env'
if (Test-Path -LiteralPath $target) { Write-Output '.env already exists; preserving it.'; exit 0 }
$bytes = New-Object byte[] 32
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($bytes)
$rng.Dispose()
$password = [BitConverter]::ToString($bytes).Replace('-', '').ToLowerInvariant()
# CreateNew is atomic: concurrent runs cannot overwrite an existing password.
try {
    $stream = [System.IO.File]::Open($target, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
} catch [System.IO.IOException] {
    if (Test-Path -LiteralPath $target) { Write-Output '.env already exists; preserving it.'; exit 0 }
    throw
}
try {
    $content = [System.Text.Encoding]::UTF8.GetBytes("POSTGRES_PASSWORD=$password" + [Environment]::NewLine)
    $stream.Write($content, 0, $content.Length)
} finally { $stream.Dispose() }
Write-Output 'Created ignored local database credentials. No secret printed.'
