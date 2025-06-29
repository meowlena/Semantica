#!/bin/bash
# Script unificado para compilar o projeto em ambientes Unix-like (Linux, macOS, WSL, Cygwin)

# Muda para o diretório raiz do projeto
cd "$(dirname "$0")/.." || exit 1

echo "======================================="
echo "   COMPILACAO DO PROJETO DE SEMANTICA   "
echo "======================================="
echo ""

# Limpar arquivos compilados anteriores
echo "Limpando arquivos compilados anteriores..."
rm -f *.cmi *.cmo avaliador testes avaliador.exe testes.exe

# Compilar módulos
echo "[1/5] Compilando Datatypes.ml..."
ocamlc -c Datatypes.ml || {
    echo "ERRO ao compilar Datatypes.ml"
    exit 1
}

echo "[2/5] Compilando Eval.ml..."
ocamlc -c Eval.ml || {
    echo "ERRO ao compilar Eval.ml"
    exit 1
}

echo "[3/5] Compilando Test.ml..."
ocamlc -c Test.ml || {
    echo "ERRO ao compilar Test.ml"
    exit 1
}

# Não usamos mais extensão .exe em nenhum ambiente
echo "[4/5] Criando executavel avaliador..."
ocamlc -o avaliador.tmp Datatypes.cmo Eval.cmo || {
    echo "ERRO ao criar o executavel avaliador"
    exit 1
}
# Garantir que não tenha extensão .exe
cp avaliador.tmp avaliador
rm -f avaliador.tmp avaliador.tmp.exe avaliador.exe

echo "[5/5] Criando executavel de testes..."
ocamlc -o testes.tmp Datatypes.cmo Eval.cmo Test.cmo || {
    echo "ERRO ao criar o executavel de testes"
    exit 1
}
# Garantir que não tenha extensão .exe
cp testes.tmp testes
rm -f testes.tmp testes.tmp.exe testes.exe

echo ""
echo "======================================="
echo "   Compilacao concluida com sucesso!   "
echo "======================================="
echo ""
echo "Para executar o avaliador: ./avaliador"
echo "Para executar os testes: ./testes"
