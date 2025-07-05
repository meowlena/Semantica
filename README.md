# Trabalho de Semântica Formal - Linguagem L2

## Interpretador para Linguagem Funcional com Referências e For Loop

Este projeto implementa um interpretador completo para a linguagem funcional L2 com referências, incluindo a extensão com o construto `for` loop, conforme especificado na disciplina de Semântica Formal.

### **Objetivos Alcançados**
- Implementação completa da linguagem L2 (spec base)
- Extensão com construto `for` loop
- Semântica operacional big-step rigorosamente seguida
- Sistema de referências e estado mutável
- Tratamento robusto de erros
- Bateria completa de testes (150+ casos)
- Build multiplataforma (Windows/Linux/Mac)
- Documentação detalhada com mapeamento formal

### **Arquitetura do Projeto**

```
Projeto Semantica/
├── Datatypes.ml                    # AST e tipos sintáticos
├── Eval.ml                         # Avaliador (semântica small-step)
├── Test.ml                         # Suite de testes completa
├── Test_For.ml                     # Testes específicos do for loop
├── README.md                       # Este arquivo (documentação principal)
├── SEMANTICA_SMALL_STEP.md         # Documentação da implementação
├── Especs_Trab_Semantica_-_2025_1.pdf # Especificação formal do trabalho
└── build/                          # Scripts de compilação
    ├── Makefile                    # Build principal (Unix/Linux)
    ├── build.ps1                   # Script PowerShell (Windows)
    └── README.md                   # Instruções de build
```

## Compilação

### Método Rápido

```bash
# Usando PowerShell (Windows)
.\build\build.ps1

# Usando Makefile (Unix/Linux/Mac)
cd build && make
```

**Nota sobre Compilação no Windows**: O script detecta automaticamente se o compilador nativo (`ocamlopt`) está disponível e compila para código nativo quando possível, o que elimina a dependência do runtime `ocamlrun`. Caso contrário, usa bytecode (`ocamlc`).

## Execução

### Executar os Testes

```bash
./testes  # Linux/Mac
.\test.exe   # Windows (CMD/PowerShell)

# Ou teste específico do for loop
./test_for  # Linux/Mac
.\test_for.exe   # Windows (CMD/PowerShell)
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

O avaliador atualmente suporta **todas** as funcionalidades da linguagem especificada:

### Construtos Básicos
- **Literais**: números inteiros (`Num`), booleanos (`Bool`) e unit (`Unit`)
- **Operações aritméticas**: soma (`+`), subtração (`-`), multiplicação (`*`), divisão (`/`)
- **Operadores de comparação**: menor que (`<`), maior que (`>`), igualdade (`=`), diferença (`!=`)
- **Operações lógicas**: conjunção (`AND`), disjunção (`OR`) com avaliação por curto-circuito

### Controle de Fluxo
- **Expressões condicionais**: `If then else` com verificação de tipos
- **Variáveis**: declaração (`Let`) e referência (`Id`) com escopo correto
- **Sequenciamento**: execução sequencial de comandos (`Seq`)
- **Laços**: `While` loops com condições booleanas

### Gerenciamento de Memória
- **Criação de referências**: `New` para alocar valores na memória
- **Desreferenciamento**: `Deref` (`!`) para acessar valores de referências
- **Atribuição**: `Asg` (`:=`) para modificar valores em referências

### Entrada/Saída
- **Impressão**: `Print` para exibir valores no console
- **Leitura**: `Read` para ler valores inteiros da entrada padrão

### Executáveis Disponíveis
- **`testes`**: Executa toda a bateria de testes automatizada
- **`test_for`**: Executa testes específicos do for loop

### Tratamento de Erros
O avaliador detecta e reporta corretamente:
- Divisão por zero
- Tipos incompatíveis em operações
- Variáveis não declaradas
- Desreferenciamento de valores não-referência
- Atribuição a valores não-referência
- Condições não-booleanas em `If` e `While`

## Nota sobre uso de IA

Foi utilizada Inteligência Artificial (GitHub Copilot) como ferramenta auxiliar para:
- Geração da documentação (README.md, comentários no código)
- Criação dos scripts de compilação (build/)
- Elaboração dos testes automatizados (Test.ml)

O código do avaliador em si (a lógica semântica) foi implementado manualmente, seguindo as especificações formais do trabalho, sem assistência direta de IA.
