# Script PowerShell para compilar o projeto de Semantica Formal
# Versão atualizada - Build completo com testes

# Muda para o diretório raiz do projeto
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

Write-Host "=======================================" -ForegroundColor Blue
Write-Host "   BUILD COMPLETO - SEMANTICA L2        " -ForegroundColor Blue
Write-Host "   (Small-Step Implementation)          " -ForegroundColor Blue
Write-Host "=======================================" -ForegroundColor Blue
Write-Host ""

# Configure o ambiente OPAM se estiver disponível
Write-Host "Configurando ambiente OCaml via OPAM..." -ForegroundColor Green
try {
    (& opam env) -split '\r?\n' | ForEach-Object { 
        if ($_ -match "=") { 
            Invoke-Expression $_ 
        }
    }
    Write-Host "Ambiente OPAM configurado com sucesso." -ForegroundColor Green
} catch {
    Write-Host "Ambiente OPAM nao encontrado. Tentando usar OCaml do PATH..." -ForegroundColor Yellow
}

# Verificar se o OCaml está instalado (após configurar OPAM)
Write-Host "Verificando instalacao do OCaml..." -ForegroundColor Cyan
try {
    $ocamlVersion = & ocamlc -version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OCaml encontrado: $ocamlVersion" -ForegroundColor Green
    } else {
        throw "OCaml nao encontrado"
    }
} catch {
    Write-Host "ERRO: OCaml nao esta instalado ou nao esta no PATH" -ForegroundColor Red
    Write-Host "Para instalar o OCaml:" -ForegroundColor Yellow
    Write-Host "1. Instale o OPAM: https://opam.ocaml.org/doc/Install.html" -ForegroundColor White
    Write-Host "2. Execute: opam init && opam install ocaml" -ForegroundColor White
    Write-Host "3. Reinicie o PowerShell e execute novamente o script" -ForegroundColor White
    Write-Host "Ou baixe o OCaml diretamente: https://ocaml.org/install" -ForegroundColor White
    exit 1
}

# Limpar arquivos compilados anteriores
Write-Host "`nLimpando arquivos compilados anteriores..." -ForegroundColor Cyan
Remove-Item -Force -ErrorAction SilentlyContinue *.cmi, *.cmo, *.exe

Write-Host "`n=== COMPILANDO MODULOS PRINCIPAIS ===" -ForegroundColor Yellow

# Compilar os módulos na ordem correta
Write-Host "`n[1/4] Compilando Datatypes.ml..." -ForegroundColor White
ocamlc -c Datatypes.ml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO ao compilar Datatypes.ml" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "`n[2/4] Compilando Eval.ml..." -ForegroundColor White
ocamlc -c Eval.ml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO ao compilar Eval.ml" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "`n[3/4] Compilando Test.ml..." -ForegroundColor White
ocamlc -c Test.ml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO ao compilar Test.ml" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "`n[4/4] Compilando Test_For.ml..." -ForegroundColor White
ocamlc -c Test_For.ml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO ao compilar Test_For.ml" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "`n=== CRIANDO EXECUTAVEIS ===" -ForegroundColor Yellow

# Compilar os executáveis de teste
Write-Host "`n[1/2] Criando executavel de testes..." -ForegroundColor White
ocamlc -o testes.exe Datatypes.cmo Eval.cmo Test.cmo
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO ao criar testes.exe" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "`n[2/2] Criando executavel do teste de FOR..." -ForegroundColor White
ocamlc -o test_for.exe Datatypes.cmo Eval.cmo Test_For.ml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO ao criar test_for.exe" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "`n=== EXECUTANDO TESTES AUTOMATICOS ===" -ForegroundColor Yellow
Write-Host "`nExecutando testes para validar a compilacao..."
.\testes.exe

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=======================================" -ForegroundColor Green
    Write-Host "   BUILD COMPLETO E TESTES PASSARAM!   " -ForegroundColor Green
    Write-Host "=======================================" -ForegroundColor Green
    Write-Host "`nExecutaveis criados:" -ForegroundColor Cyan
    Write-Host "  testes.exe     - Bateria completa de testes" -ForegroundColor Yellow
    Write-Host "  test_for.exe   - Teste interativo do for loop" -ForegroundColor Yellow
    Write-Host "`nPara testar:"
    Write-Host "  .\testes.exe      - Executar todos os testes" -ForegroundColor Cyan
    Write-Host "  .\test_for.exe    - Testar for loop interativo" -ForegroundColor Cyan
    Write-Host "`nImplementacao small-step da linguagem L2 pronta!" -ForegroundColor Green
} else {
    Write-Host "`n=======================================" -ForegroundColor Red
    Write-Host "   TESTES FALHARAM!                     " -ForegroundColor Red
    Write-Host "=======================================" -ForegroundColor Red
    Write-Host "Verifique a implementacao e tente novamente." -ForegroundColor Red
    exit $LASTEXITCODE
}
