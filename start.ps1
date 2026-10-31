$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    docker compose up -d --build
    if ($LASTEXITCODE -ne 0) { throw '服务启动失败，请查看 Docker Desktop。' }
    Write-Host '网页：http://localhost:8080'
    Write-Host '后端文档：http://localhost:8000/api/v1/docs'
    Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -eq 'WLAN' } | ForEach-Object {
        Write-Host "手机预览：http://$($_.IPAddress):8080"
    }
} finally { Pop-Location }
