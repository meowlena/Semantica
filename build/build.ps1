# Script PowerShell para compilar o projeto de Semantica Formal
# Substitui o uso do make no ambiente Windows

# Muda para o diretório raiz do projeto
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

Write-Host "=======================================" -ForegroundColor Blue
Write-Host "   COMPILACAO DO PROJETO DE SEMANTICA   " -ForegroundColor Blue
Write-Host "=======================================" -ForegroundColor Blue
Write-Host ""

# Configure o ambiente OPAM se estiver disponível
try {
    Write-Host "Configurando ambiente OCaml via OPAM..." -ForegroundColor Green
    (& opam env) -split '\r?\n' | ForEach-Object { 
        if ($_ -match "=") { 
            Invoke-Expression $_ 
        }
    }
    Write-Host "Ambiente OPAM configurado com sucesso." -ForegroundColor Green
} catch {
    Write-Host "Ambiente OPAM nao encontrado. Usando OCaml do PATH..." -ForegroundColor Yellow
}

# Limpar arquivos compilados anteriores
Write-Host "`nLimpando arquivos compilados anteriores..." -ForegroundColor Cyan
Remove-Item -Force -ErrorAction SilentlyContinue *.cmi, *.cmo, avaliador, avaliador.exe, avaliador.tmp, avaliador.tmp.exe, testes, testes.exe, testes.tmp, testes.tmp.exe

# Compilar os módulos na ordem correta
Write-Host "`n[1/5] Compilando Datatypes.ml..." -ForegroundColor White
ocamlc -c Datatypes.ml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO ao compilar Datatypes.ml" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "`n[2/5] Compilando Eval.ml..." -ForegroundColor White
ocamlc -c Eval.ml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO ao compilar Eval.ml" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "`n[3/5] Compilando Test.ml..." -ForegroundColor White
ocamlc -c Test.ml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO ao compilar Test.ml" -ForegroundColor Red
    exit $LASTEXITCODE
}

# Compilar o avaliador
Write-Host "`n[4/5] Criando executavel avaliador..." -ForegroundColor White
ocamlc -o avaliador.tmp Datatypes.cmo Eval.cmo
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO ao criar o executavel avaliador" -ForegroundColor Red
    exit $LASTEXITCODE
}
# Garantir que o arquivo não tenha extensão .exe
Copy-Item -Path "avaliador.tmp" -Destination "avaliador" -Force
Remove-Item -Force -ErrorAction SilentlyContinue "avaliador.tmp", "avaliador.tmp.exe", "avaliador.exe"

# Compilar os testes
Write-Host "`n[5/5] Criando executavel de testes..." -ForegroundColor White
ocamlc -o testes.tmp Datatypes.cmo Eval.cmo Test.cmo
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO ao criar o executavel de testes" -ForegroundColor Red
    exit $LASTEXITCODE
}
# Garantir que o arquivo não tenha extensão .exe
Copy-Item -Path "testes.tmp" -Destination "testes" -Force
Remove-Item -Force -ErrorAction SilentlyContinue "testes.tmp", "testes.tmp.exe", "testes.exe"

Write-Host "`n=======================================" -ForegroundColor Green
Write-Host "   Compilacao concluida com sucesso!   " -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host "`nPara executar o avaliador: " -NoNewline
Write-Host ".\avaliador" -ForegroundColor Yellow
Write-Host "Para executar os testes: " -NoNewline
Write-Host ".\testes" -ForegroundColor Yellow
