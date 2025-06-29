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
ocamlc -o avaliador.exe Datatypes.cmo Eval.cmo
if %ERRORLEVEL% NEQ 0 (
    echo ERRO ao criar o executavel avaliador
    exit /b %ERRORLEVEL%
)

echo [5/5] Criando executavel de testes...
ocamlc -o testes.exe Datatypes.cmo Eval.cmo Test.cmo
if %ERRORLEVEL% NEQ 0 (
    echo ERRO ao criar o executavel de testes
    exit /b %ERRORLEVEL%
)

echo.
echo =======================================
echo   Compilacao concluida com sucesso!
echo =======================================
echo.
echo Para executar o avaliador: .\avaliador.exe
echo Para executar os testes: .\testes.exe
