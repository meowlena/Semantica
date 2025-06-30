# Script wrapper para chamar o compilador na pasta build
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
try {
    # Executar diretamente o script principal de compilação (build.ps1)
    & "$scriptDir\build.ps1"
} catch {
    Write-Host "Erro na compilação: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
