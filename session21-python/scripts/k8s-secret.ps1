param([Parameter(Mandatory=$true)][string]$Context)
$ErrorActionPreference='Stop'
$envFile=Join-Path $PSScriptRoot '..\.env'
if(!(Test-Path -LiteralPath $envFile)){throw 'Run init-local.ps1 first.'}
$password=((Get-Content -LiteralPath $envFile | Where-Object {$_ -match '^POSTGRES_PASSWORD='}) -split '=',2)[1]
if(!$password){throw 'Missing local database password.'}
$secret=@{
 apiVersion='v1';kind='Secret';metadata=@{name='kitledger-db';namespace='kitledger'};type='Opaque'
 stringData=@{POSTGRES_PASSWORD=$password;DATABASE_URL="postgresql+psycopg://kitledger:$password@postgres:5432/kitledger"}
}
$secret | ConvertTo-Json -Depth 5 -Compress | kubectl --context $Context apply -f -
if($LASTEXITCODE -ne 0){throw 'Secret creation failed'}
