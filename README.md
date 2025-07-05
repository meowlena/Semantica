# Semântica Formal - Avaliador Small-Step para Linguagem L2

## Interpretador Small-Step com Referências, Substituição Textual e Validação de Tipos

Este projeto implementa um avaliador **small-step** completo para a linguagem funcional L2 com referências, seguindo rigorosamente a especificação formal da disciplina de Semântica Formal.

### **Características Principais**
- **Semântica Small-Step Pura**: Implementação fiel às regras (e, σ) → (e', σ')
- **Substituição Textual**: Implementação da regra E-Let2 com [v/x]e
- **Validação de Tipos**: Verificação de tipos em expressões condicionais
- **Sistema de Referências**: Gerenciamento completo de memória mutável
- **Testes Abrangentes**: Suite modular com 14 categorias de testes
- **Build Multiplataforma**: Scripts otimizados para Windows/Linux/Mac
- **Conformidade Formal**: Todos os testes do professor validados
- **For Loop**: Funcionalidade extra implementada para nota total

### **Arquitetura do Projeto**

```
Projeto Semantica/
├── Datatypes.ml                    # AST e tipos da linguagem L2
├── Eval.ml                         # Avaliador small-step (núcleo do projeto)
├── Test.ml                         # Suite completa de testes (modular)
├── Test_For.ml                     # Testes específicos do for loop
├── Teacher_tests.ml                # Testes do professor (validação)
├── README.md                       # Documentação principal (este arquivo)
├── SEMANTICA_SMALL_STEP.md         # Documentação técnica detalhada
├── Especs_Trab_Semantica_-_2025_1.pdf # Especificação formal
└── build/                          # Sistema de build
    ├── Makefile                    # Build Unix/Linux/Mac
    ├── build.ps1                   # Script PowerShell (Windows)
    └── README.md                   # Instruções de compilação
```

## Compilação e Execução

### Compilação Automática

**Windows (PowerShell):**
```powershell
cd build
.\build.ps1
```

**Linux/Mac:**
```bash
cd build
make all
```

### Executáveis Gerados

Após a compilação, os seguintes executáveis estão disponíveis:

- **`test`** (Linux/Mac) / **`test.exe`** (Windows): Suite completa de testes (200+ casos)
- **`test_for`** (Linux/Mac) / **`test_for.exe`** (Windows): Testes específicos do for loop
- **`teacher_tests`** (Linux/Mac) / **`teacher_tests.exe`** (Windows): Testes do professor (validação formal)

**Execução:**
```bash
# Linux/Mac
./test
./test_for
./teacher_tests

# Windows (CMD/PowerShell)
.\test.exe
.\test_for.exe
.\teacher_tests.exe
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
- **For Loops**: Implementação adicional para nota total (funcionalidade extra)

### Gerenciamento de Memória
- **Criação de referências**: `New` para alocar valores na memória
- **Desreferenciamento**: `Deref` (`!`) para acessar valores de referências
- **Atribuição**: `Asg` (`:=`) para modificar valores em referências

### Entrada/Saída
- **Impressão**: `Print` para exibir valores no console
- **Leitura**: `Read` para ler valores inteiros da entrada padrão

### Executáveis Disponíveis
- **`test`** (Linux/Mac) / **`test.exe`** (Windows): Executa toda a bateria de testes automatizada
- **`test_for`** (Linux/Mac) / **`test_for.exe`** (Windows): Executa testes específicos do for loop (funcionalidade extra)
- **`teacher_tests`** (Linux/Mac) / **`teacher_tests.exe`** (Windows): Testes do professor para validação formal

### Tratamento de Erros
O avaliador detecta e reporta corretamente:
- Divisão por zero
- Tipos incompatíveis em operações
- Variáveis não declaradas
- Desreferenciamento de valores não-referência
- Atribuição a valores não-referência
- Condições não-booleanas em `If` e `While`


## Funcionalidade Extra Para Nota Total

Este projeto implementa **For Loops** como funcionalidade adicional para obtenção da nota total. O For Loop:

- **Sintaxe**: `For(variavel, inicio, fim, corpo)`
- **Semântica**: Executa o corpo com a variável iterando do valor inicial ao final
- **Implementação**: Desugaring para While com referências e Let
- **Testes**: Suite completa incluindo casos extremos (ranges vazios, unitários)
- **Validação**: Testes específicos em `Test_For.ml` e integrados em `Test.ml`

Exemplo de uso:
```ocaml
For("i", Num 1, Num 5, Print(Id "i"))  (* Imprime 1, 2, 3, 4, 5 *)
```

## Nota sobre uso de IA

Foi utilizada Inteligência Artificial (GitHub Copilot) como ferramenta auxiliar para:
- Geração da documentação (README.md, comentários no código)
- Criação dos scripts de compilação (build/)
- Elaboração dos testes automatizados (Test.ml)

O código do avaliador em si (a lógica semântica) foi implementado manualmente, seguindo as especificações formais do trabalho, sem assistência direta de IA.