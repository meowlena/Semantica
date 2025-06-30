#!/bin/bash
# Script para compilar o projeto OCaml em ambientes Unix-like (Linux, macOS, WSL, Cygwin)

# Muda para o diretório raiz do projeto
cd "$(dirname "$0")/.." || exit 1

echo "======================================="
echo "   COMPILACAO DO PROJETO DE SEMANTICA   "
echo "======================================="
echo ""

# Limpar arquivos compilados anteriores
echo "Limpando arquivos compilados anteriores..."
rm -f *.cmi *.cmo avaliador testes test_for

# Compilar módulos
echo "[1/8] Compilando Datatypes.ml..."
ocamlc -c Datatypes.ml || {
    echo "ERRO ao compilar Datatypes.ml"
    exit 1
}

echo "[2/8] Compilando Eval.ml..."
ocamlc -c Eval.ml || {
    echo "ERRO ao compilar Eval.ml"
    exit 1
}

echo "[3/8] Compilando Main.ml..."
ocamlc -c Main.ml || {
    echo "ERRO ao compilar Main.ml"
    exit 1
}

echo "[4/8] Compilando Test.ml..."
ocamlc -c Test.ml || {
    echo "ERRO ao compilar Test.ml"
    exit 1
}

echo "[5/8] Compilando Test_For.ml..."
ocamlc -c Test_For.ml || {
    echo "ERRO ao compilar Test_For.ml"
    exit 1
}

echo "[6/8] Criando executavel avaliador..."
ocamlc -o avaliador.tmp Datatypes.cmo Eval.cmo Main.cmo || {
    echo "ERRO ao criar o executavel avaliador"
    exit 1
}
# Garantir que não tenha extensão .exe
cp avaliador.tmp avaliador
rm -f avaliador.tmp avaliador.tmp.exe avaliador.exe

echo "[7/8] Criando executavel de testes..."
ocamlc -o testes.tmp Datatypes.cmo Eval.cmo Test.cmo || {
    echo "ERRO ao criar o executavel de testes"
    exit 1
}
# Garantir que não tenha extensão .exe
cp testes.tmp testes
rm -f testes.tmp testes.tmp.exe testes.exe

echo "[8/8] Criando executavel de teste do for..."
ocamlc -o test_for.tmp Datatypes.cmo Eval.cmo Test_For.cmo || {
    echo "ERRO ao criar o executavel de teste do for"
    exit 1
}
# Garantir que não tenha extensão .exe
cp test_for.tmp test_for
rm -f test_for.tmp test_for.tmp.exe test_for.exe

echo ""
echo "======================================="
echo "   Compilacao concluida com sucesso!   "
echo "======================================="
echo ""
echo "Para executar o avaliador: ./avaliador"
echo "Para executar os testes: ./testes"
echo "Para executar os testes interativos: ./testes -i"
echo "Para executar o teste do for loop: ./test_for"
