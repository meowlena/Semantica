@echo off
REM ---------------------------------------------------------
REM Script principal de compilação para projeto de Semântica
REM ---------------------------------------------------------
REM Localizado na pasta build/ para manter organização
REM
REM Este script:
REM 1. Detecta o ambiente (PowerShell ou CMD)
REM 2. Compila todos os módulos OCaml
REM 3. Cria os executáveis finais
REM ---------------------------------------------------------

REM Configurações
set ROOT_DIR=%~dp0..
set OUTPUT_DIR=%ROOT_DIR%

REM Detecta se está sendo executado no PowerShell
if defined PSModulePath (
    echo Detectado PowerShell. Executando script PowerShell...
    powershell -ExecutionPolicy Bypass -File "%~dp0build.ps1"
    exit /b %errorlevel%
)

REM Se chegou aqui, está sendo executado no CMD
cd /d "%ROOT_DIR%"

echo =======================================
echo   COMPILACAO DO PROJETO DE SEMANTICA
echo =======================================
echo.

REM Limpar arquivos compilados anteriores
echo Limpando arquivos compilados anteriores...
del /F /Q *.cmi *.cmo avaliador avaliador.exe testes testes.exe testes_interativo testes_interativo.exe 2>nul

REM Compilar módulos
echo [1/8] Compilando Datatypes.ml...
ocamlc -c Datatypes.ml
if %ERRORLEVEL% NEQ 0 (
    echo ERRO ao compilar Datatypes.ml
    exit /b %ERRORLEVEL%
)

echo [2/8] Compilando Eval.ml...
ocamlc -c Eval.ml
if %ERRORLEVEL% NEQ 0 (
    echo ERRO ao compilar Eval.ml
    exit /b %ERRORLEVEL%
)

echo [3/8] Compilando Main.ml...
ocamlc -c Main.ml
if %ERRORLEVEL% NEQ 0 (
    echo ERRO ao compilar Main.ml
    exit /b %ERRORLEVEL%
)

echo [4/8] Compilando Test.ml...
ocamlc -c Test.ml
if %ERRORLEVEL% NEQ 0 (
    echo ERRO ao compilar Test.ml
    exit /b %ERRORLEVEL%
)

echo [5/8] Compilando Test_Interactive.ml...
ocamlc -c Test_Interactive.ml
if %ERRORLEVEL% NEQ 0 (
    echo ERRO ao compilar Test_Interactive.ml
    exit /b %ERRORLEVEL%
)

echo [6/8] Criando executavel avaliador...
REM Usando copy para garantir que o executável não tenha extensão .exe no Windows
ocamlc -o avaliador.tmp Datatypes.cmo Eval.cmo Main.cmo
if %ERRORLEVEL% NEQ 0 (
    echo ERRO ao criar o executavel avaliador
    exit /b %ERRORLEVEL%
)
copy /Y avaliador.tmp avaliador >nul
del /F /Q avaliador.tmp avaliador.tmp.exe avaliador.exe >nul

echo [7/8] Criando executavel de testes...
ocamlc -o testes.tmp Datatypes.cmo Eval.cmo Test.cmo
if %ERRORLEVEL% NEQ 0 (
    echo ERRO ao criar o executavel de testes
    exit /b %ERRORLEVEL%
)
copy /Y testes.tmp testes >nul
del /F /Q testes.tmp testes.tmp.exe testes.exe >nul

echo [8/8] Criando executavel de testes interativo...
ocamlc -o testes_interativo.tmp Datatypes.cmo Eval.cmo Test_Interactive.cmo
if %ERRORLEVEL% NEQ 0 (
    echo ERRO ao criar o executavel de testes interativo
    exit /b %ERRORLEVEL%
)
copy /Y testes_interativo.tmp testes_interativo >nul
del /F /Q testes_interativo.tmp testes_interativo.tmp.exe testes_interativo.exe >nul

echo.
echo =======================================
echo   Compilacao concluida com sucesso!
echo =======================================
echo.
echo Para executar o avaliador: .\avaliador
echo Para executar os testes: .\testes
echo Para executar os testes interativos: .\testes_interativo
