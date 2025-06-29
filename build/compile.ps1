# Script wrapper para chamar o compilador na pasta build
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location "$scriptDir\build"
try {
    # Executar diretamente o script principal de compilação
    & "$scriptDir\build\compile.bat"
} finally {
    Pop-Location
}
