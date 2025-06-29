# Trabalho de Semântica

## Avaliador para Linguagem Funcional com Referências

Este projeto implementa um avaliador (interpretador) para uma linguagem funcional simples com referências, 
conforme especificado na disciplina de Semântica Formal.

## Estrutura do Projeto

- `Datatypes.ml`: Define os tipos sintáticos da linguagem (AST)
- `Eval.ml`: Implementa o avaliador (semântica operacional)
- `Test.ml`: Contém testes para o avaliador
- `Makefile`: Automatiza a compilação do projeto

## Compilação

### Usando Make (recomendado)

```bash
# Compilar tudo (avaliador e testes)
make all

# Compilar apenas o avaliador
make avaliador

# Compilar apenas os testes
make testes

# Limpar arquivos compilados
make clean  # Linux/Mac
make win-clean  # Windows
```

### Compilação Manual (Sem Make)

Se o utilitário Make não estiver disponível (comum em algumas máquinas da faculdade), você pode compilar o projeto diretamente usando o compilador OCaml:

```bash
# Compilar módulos na ordem correta (importante respeitar a ordem)
ocamlc -c Datatypes.ml     # Compila o módulo de tipos
ocamlc -c Eval.ml          # Compila o avaliador (depende de Datatypes)
ocamlc -c Test.ml          # Compila os testes (depende de Datatypes e Eval)

# Linkar o avaliador (sem testes)
ocamlc -o avaliador Datatypes.cmo Eval.cmo

# Linkar com os testes
ocamlc -o testes Datatypes.cmo Eval.cmo Test.cmo
```

### Limpeza Manual (Sem Make)

Para limpar os arquivos compilados manualmente:

```bash
# Em Linux/Mac
rm -f *.cmi *.cmo avaliador testes

# Em Windows (PowerShell)
Remove-Item -Force *.cmi, *.cmo, avaliador.exe, testes.exe -ErrorAction SilentlyContinue

# Em Windows (CMD)
del *.cmi *.cmo avaliador.exe testes.exe
```

## Execução

### Executar o Avaliador

```bash
./avaliador  # Linux/Mac
.\avaliador.exe  # Windows
```

### Executar os Testes

```bash
./testes  # Linux/Mac
.\testes.exe  # Windows
```

### Testes Interativos no REPL

```bash
# Iniciar o REPL do OCaml
ocaml

# Carregar os módulos compilados
#load "Datatypes.cmo";;
#load "Eval.cmo";;
open Datatypes;;
open Eval;;

# Exemplo: avaliar uma expressão
eval (Num 42) estado_inicial;;
```

### Desenvolvimento sem Compilação

Se não for possível compilar os arquivos (por falta de permissões ou por qualquer outro motivo), você ainda pode trabalhar de forma interativa:

```bash
# Iniciar o REPL do OCaml
ocaml

# Carregar os arquivos fonte diretamente
#use "Datatypes.ml";;
#use "Eval.ml";;

# Testar expressões
let result = eval (Num 42) estado_inicial;;
let result = eval (Binop(Sum, Num 10, Num 20)) estado_inicial;;

# Para executar todos os testes
#use "Test.ml";;
```

## Implementação Atual

O avaliador atualmente suporta:
- Literais: números, booleanos e unit
- Operações aritméticas: soma, subtração, multiplicação, divisão
- Operadores de comparação: <, >, =, !=
- Operações lógicas: and, or

## Próximos Passos

- Implementar variáveis (`Let` e `Id`)
- Implementar manipulação de memória (`New`, `Deref`, `Asg`)
- Implementar controle de fluxo (`If`, `Wh`, `Seq`)
- Implementar I/O (`Print`, `Read`)

## Solução de Problemas Comuns

### Arquivo não encontrado
```
Error: Cannot find file Datatypes.ml
```
Verifique se você está no diretório correto. Todos os caminhos nos comandos são relativos ao diretório onde você executa os comandos.

### Módulo não encontrado
```
Error: Unbound module Datatypes
```
Certifique-se de ter compilado o módulo Datatypes antes de compilar outros módulos que dependem dele.

### Falha ao carregar objeto
```
Error: Cannot find file datatypes.cmo
```
O nome do arquivo compilado deve corresponder ao nome exato do arquivo fonte, incluindo maiúsculas e minúsculas. Em alguns sistemas, `Datatypes.ml` gera `datatypes.cmo` (minúsculo) e em outros `Datatypes.cmo` (maiúsculo).

### Comandos do Make não funcionam
Se o Make não estiver disponível ou não funcionar corretamente, use os comandos de compilação manual listados acima.

## Nota sobre uso de IA

Foi utilizada Inteligência Artificial (GitHub Copilot) como ferramenta auxiliar para:
- Geração da documentação (README.md, comentários no código)
- Criação do Makefile
- Elaboração dos testes (Test.ml)

O código do avaliador em si (a lógica semântica) foi implementado manualmente, seguindo as especificações formais do trabalho, sem assistência direta de IA.