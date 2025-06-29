@echo off
REM ---------------------------------------------------------
REM Script universal para compilação do projeto de Semântica
REM ---------------------------------------------------------
REM Este script detecta o tipo de terminal e redireciona para 
REM o script apropriado (PowerShell ou CMD)

REM Muda para o diretório do script
cd /d "%~dp0"

REM Detecta se está sendo executado no PowerShell
if defined PSModulePath (
    echo Detectado PowerShell. Executando script PowerShell...
    powershell -ExecutionPolicy Bypass -File "%~dp0build.ps1"
    exit /b %errorlevel%
)

REM Volta para o diretório raiz do projeto
cd ..

REM Se chegou aqui, está sendo executado no CMD
echo =======================================
echo   COMPILACAO DO PROJETO DE SEMANTICA
echo =======================================
echo.

REM Verificar se o OCaml está instalado
echo Verificando instalacao do OCaml...
ocamlc -version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERRO: OCaml nao esta instalado ou nao esta no PATH
    echo Para instalar o OCaml:
    echo 1. Instale o OPAM: https://opam.ocaml.org/doc/Install.html
    echo 2. Execute: opam init ^&^& opam install ocaml
    echo 3. Configure o ambiente: eval $(opam env^)
    echo Ou baixe o OCaml diretamente: https://ocaml.org/install
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('ocamlc -version 2^>nul') do echo OCaml encontrado: %%i
)

REM Limpar arquivos compilados anteriores
echo Limpando arquivos compilados anteriores...
del /F /Q *.cmi *.cmo avaliador.exe testes.exe 2>nul

REM Compilar módulos
echo [1/5] Compilando Datatypes.ml...
ocamlc -c Datatypes.ml
if %ERRORLEVEL% NEQ 0 (
    echo ERRO ao compilar Datatypes.ml
    exit /b %ERRORLEVEL%
)

echo [2/5] Compilando Eval.ml...
ocamlc -c Eval.ml
if %ERRORLEVEL% NEQ 0 (
    echo ERRO ao compilar Eval.ml
    exit /b %ERRORLEVEL%
)

echo [3/5] Compilando Test.ml...
ocamlc -c Test.ml
if %ERRORLEVEL% NEQ 0 (
    echo ERRO ao compilar Test.ml
    exit /b %ERRORLEVEL%
)

echo [4/5] Criando executavel avaliador...
REM Tentar compilação nativa primeiro, depois bytecode
ocamlopt -o avaliador.exe Datatypes.ml Eval.ml >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Avaliador compilado para codigo nativo
) else (
    echo Compilacao nativa nao disponivel, usando bytecode...
    ocamlc -o avaliador.exe Datatypes.cmo Eval.cmo
    if %ERRORLEVEL% NEQ 0 (
        echo ERRO ao criar o executavel avaliador
        exit /b %ERRORLEVEL%
    )
)

echo [5/5] Criando executavel de testes...
REM Tentar compilação nativa primeiro, depois bytecode
ocamlopt -o testes.exe Datatypes.ml Eval.ml Test.ml >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Testes compilados para codigo nativo
) else (
    echo Compilacao nativa nao disponivel, usando bytecode...
    ocamlc -o testes.exe Datatypes.cmo Eval.cmo Test.cmo
    if %ERRORLEVEL% NEQ 0 (
        echo ERRO ao criar o executavel de testes
        exit /b %ERRORLEVEL%
    )
)

echo.
echo =======================================
echo   Compilacao concluida com sucesso!
echo =======================================
echo.
echo Para executar o avaliador: .\avaliador.exe
echo Para executar os testes: .\testes.exe
