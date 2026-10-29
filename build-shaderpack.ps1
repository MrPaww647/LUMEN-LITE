$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$pack = Join-Path $root "LUMEN-LITE.zip"
if (Test-Path $pack) { Remove-Item $pack -Force }
Compress-Archive -Path (Join-Path $root "pack.mcmeta"), (Join-Path $root "shaders") -DestinationPath $pack -CompressionLevel Optimal
Write-Host "Created shaderpack: $pack" -ForegroundColor Green
