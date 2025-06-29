# Trabalho de Semântica

## Avaliador para Linguagem Funcional com Referências

Este projeto implementa um avaliador (interpretador) para uma linguagem funcional simples com referências, 
conforme especificado na disciplina de Semântica Formal.

## Estrutura do Projeto

### Arquivos Principais
- `Datatypes.ml`: Define os tipos sintáticos da linguagem (AST)
- `Eval.ml`: Implementa o avaliador (semântica operacional)
- `Test.ml`: Contém testes para o avaliador

### Estrutura Organizacional
- `/build`: Contém todos os scripts de compilação (separados da implementação)
- `COMPILACAO.md`: Instruções completas de compilação
- `AVALIADOR.md`: Documentação do avaliador
- `GUIA_REFERENCIA.md`: Guia de referência da linguagem

## Compilação

Para instruções detalhadas sobre compilação, consulte o arquivo [COMPILACAO.md](COMPILACAO.md).

### Método Rápido

```bash
# Usando Make dentro da pasta build
cd build && make

# Ou usando os scripts diretamente
.\build\compile.bat  # Windows
./build/compile.sh   # Linux/Mac/Unix

# Ou usando os scripts diretamente
.\build\compile.bat  # Windows
./build/compile.sh   # Linux/Mac/Unix
```

Todos os arquivos relacionados à compilação estão na pasta `build/` para manter
a separação entre o código da implementação e os scripts de construção.

```
build/
  ├── Makefile       # Makefile principal
  ├── compile.bat    # Script unificado para Windows
  ├── compile.sh     # Script unificado para Unix/Linux
  └── outros scripts auxiliares
```

# Em Windows (CMD)
del *.cmi *.cmo avaliador testes
```

## Execução

### Executar o Avaliador

```bash
./avaliador  # Linux/Mac
.\avaliador.exe  # Windows (CMD/PowerShell)
```

### Executar os Testes

```bash
./testes  # Linux/Mac
.\testes.exe   # Windows (CMD/PowerShell)
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
- Criação do Makefile e scripts de compilação (build/)
- Elaboração dos scripts de build multiplataforma (Windows/Unix)
- Elaboração dos testes (Test.ml)

O código do avaliador em si (a lógica semântica) foi implementado manualmente, seguindo as especificações formais do trabalho, sem assistência direta de IA.