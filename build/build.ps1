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

# Verificar se o ocamlrun está disponível
Write-Host "Verificando runtime do OCaml..." -ForegroundColor Cyan
try {
    & ocamlrun -version 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OCaml runtime (ocamlrun) encontrado" -ForegroundColor Green
    } else {
        Write-Host "AVISO: ocamlrun nao encontrado no PATH" -ForegroundColor Yellow
        Write-Host "Executaveis serao compilados para codigo nativo quando possivel" -ForegroundColor Yellow
    }
} catch {
    Write-Host "AVISO: ocamlrun nao encontrado no PATH" -ForegroundColor Yellow
    Write-Host "Executaveis serao compilados para codigo nativo quando possivel" -ForegroundColor Yellow
}

# Limpar arquivos compilados anteriores
Write-Host "`nLimpando arquivos compilados anteriores..." -ForegroundColor Cyan
Remove-Item -Force -ErrorAction SilentlyContinue *.cmi, *.cmo, avaliador.exe, testes.exe, testes_interativo.exe

# Compilar os módulos na ordem correta
Write-Host "`n[1/8] Compilando Datatypes.ml..." -ForegroundColor White
ocamlc -c Datatypes.ml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO ao compilar Datatypes.ml" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "`n[2/8] Compilando Eval.ml..." -ForegroundColor White
ocamlc -c Eval.ml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO ao compilar Eval.ml" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "`n[3/8] Compilando Main.ml..." -ForegroundColor White
ocamlc -c Main.ml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO ao compilar Main.ml" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "`n[4/8] Compilando Test.ml..." -ForegroundColor White
ocamlc -c Test.ml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO ao compilar Test.ml" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "`n[5/8] Compilando Test_Interactive.ml..." -ForegroundColor White
ocamlc -c Test_Interactive.ml
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO ao compilar Test_Interactive.ml" -ForegroundColor Red
    exit $LASTEXITCODE
}

# Compilar o avaliador
Write-Host "`n[6/8] Criando executavel avaliador..." -ForegroundColor White
# Tentar compilação nativa primeiro, depois bytecode
try {
    & ocamlopt -o avaliador.exe Datatypes.ml Eval.ml Main.ml 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Avaliador compilado para codigo nativo" -ForegroundColor Green
    } else {
        throw "Compilação nativa falhou"
    }
} catch {
    Write-Host "Compilacao nativa nao disponivel, usando bytecode..." -ForegroundColor Yellow
    ocamlc -o avaliador.exe Datatypes.cmo Eval.cmo Main.cmo
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERRO ao criar o executavel avaliador" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

# Compilar os testes
Write-Host "`n[7/8] Criando executavel de testes..." -ForegroundColor White
# Tentar compilação nativa primeiro, depois bytecode
try {
    & ocamlopt -o testes.exe Datatypes.ml Eval.ml Test.ml 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Testes compilados para codigo nativo" -ForegroundColor Green
    } else {
        throw "Compilação nativa falhou"
    }
} catch {
    Write-Host "Compilacao nativa nao disponivel, usando bytecode..." -ForegroundColor Yellow
    ocamlc -o testes.exe Datatypes.cmo Eval.cmo Test.cmo
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERRO ao criar o executavel de testes" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

# Compilar o sistema de testes interativo
Write-Host "`n[8/8] Criando executavel de testes interativo..." -ForegroundColor White
# Tentar compilação nativa primeiro, depois bytecode
try {
    & ocamlopt -o testes_interativo.exe Datatypes.ml Eval.ml Test_Interactive.ml 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Testes interativos compilados para codigo nativo" -ForegroundColor Green
    } else {
        throw "Compilação nativa falhou"
    }
} catch {
    Write-Host "Compilacao nativa nao disponivel, usando bytecode..." -ForegroundColor Yellow
    ocamlc -o testes_interativo.exe Datatypes.cmo Eval.cmo Test_Interactive.cmo
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERRO ao criar o executavel de testes interativo" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

Write-Host "`n=======================================" -ForegroundColor Green
Write-Host "   Compilacao concluida com sucesso!   " -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host "`nPara executar o avaliador: " -NoNewline
Write-Host ".\avaliador.exe" -ForegroundColor Yellow
Write-Host "Para executar os testes: " -NoNewline
Write-Host ".\testes.exe" -ForegroundColor Yellow
Write-Host "Para executar os testes interativos: " -NoNewline
Write-Host ".\testes_interativo.exe" -ForegroundColor Cyan
