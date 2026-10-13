$ErrorActionPreference = 'Stop'
$target = Join-Path $PSScriptRoot '..\.env'
if (Test-Path -LiteralPath $target) { Write-Output '.env already exists; preserving it.'; exit 0 }
$bytes = New-Object byte[] 32
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($bytes)
$rng.Dispose()
$password = [BitConverter]::ToString($bytes).Replace('-', '').ToLowerInvariant()
[System.IO.File]::WriteAllText($target, "POSTGRES_PASSWORD=$password" + [Environment]::NewLine)
Write-Output 'Created ignored local database credentials. No secret printed.'
