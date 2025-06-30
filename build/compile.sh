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
rm -f *.cmi *.cmo avaliador testes testes_interativo test_for avaliador.exe testes.exe testes_interativo.exe test_for.exe

# Compilar módulos
echo "[1/9] Compilando Datatypes.ml..."
ocamlc -c Datatypes.ml || {
    echo "ERRO ao compilar Datatypes.ml"
    exit 1
}

echo "[2/9] Compilando Eval.ml..."
ocamlc -c Eval.ml || {
    echo "ERRO ao compilar Eval.ml"
    exit 1
}

echo "[3/9] Compilando Main.ml..."
ocamlc -c Main.ml || {
    echo "ERRO ao compilar Main.ml"
    exit 1
}

echo "[4/9] Compilando Test.ml..."
ocamlc -c Test.ml || {
    echo "ERRO ao compilar Test.ml"
    exit 1
}

echo "[5/9] Compilando Test_Interactive.ml..."
ocamlc -c Test_Interactive.ml || {
    echo "ERRO ao compilar Test_Interactive.ml"
    exit 1
}

echo "[6/9] Compilando Test_For.ml..."
ocamlc -c Test_For.ml || {
    echo "ERRO ao compilar Test_For.ml"
    exit 1
}

# Não usamos mais extensão .exe em nenhum ambiente
echo "[7/9] Criando executavel avaliador..."
ocamlc -o avaliador.tmp Datatypes.cmo Eval.cmo Main.cmo || {
    echo "ERRO ao criar o executavel avaliador"
    exit 1
}
# Garantir que não tenha extensão .exe
cp avaliador.tmp avaliador
rm -f avaliador.tmp avaliador.tmp.exe avaliador.exe

echo "[8/9] Criando executavel de testes..."
ocamlc -o testes.tmp Datatypes.cmo Eval.cmo Test.cmo || {
    echo "ERRO ao criar o executavel de testes"
    exit 1
}
# Garantir que não tenha extensão .exe
cp testes.tmp testes
rm -f testes.tmp testes.tmp.exe testes.exe

echo "[9/9] Criando executavel de testes interativo..."
ocamlc -o testes_interativo.tmp Datatypes.cmo Eval.cmo Test_Interactive.cmo || {
    echo "ERRO ao criar o executavel de testes interativo"
    exit 1
}
# Garantir que não tenha extensão .exe
cp testes_interativo.tmp testes_interativo
rm -f testes_interativo.tmp testes_interativo.tmp.exe testes_interativo.exe

echo "[10/10] Criando executavel de teste do for..."
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
echo "Para executar os testes interativos: ./testes_interativo"
echo "Para executar o teste do for loop: ./test_for"
