param([switch]$Remote)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {
    $tree = @(git ls-files)
    $guide = Get-Content -LiteralPath SUBMISSION-GUIDE.md -Raw -Encoding UTF8
    $pattern = 'https://github.com/YashSensei/devops-assignment/blob/main/([A-Za-z0-9_./-]+/README\.md)'
    $paths = @([regex]::Matches($guide, $pattern) | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
    if ($paths.Count -ne 20) { throw "Expected 20 unique README targets; found $($paths.Count)." }
    foreach ($path in $paths) {
        if (!($tree -ccontains $path)) { throw "Not tracked with exact case: $path" }
        $url = "https://github.com/YashSensei/devops-assignment/blob/main/$path"
        if ($Remote) {
            $response = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -TimeoutSec 30
            if ($response.StatusCode -ne 200) { throw "Public URL failed: $url" }
        }
        Write-Output "PASS $url"
    }
    Write-Output "Verified 20 case-sensitive tracked README targets. Remote HTTP checks: $Remote"
} finally { Pop-Location }
