# Trabalho de Semântica Formal - 2025/1

Este projeto implementa um interpretador para uma linguagem funcional com referências e operações imperativas, desenvolvido como parte da disciplina de Semântica Formal na UFRGS.

## Descrição

O projeto consiste na implementação de uma linguagem de programação simples que combina características funcionais e imperativas, incluindo:

- **Tipos de dados**: Inteiros, Booleanos, Referências e Unit
- **Operações**: Aritméticas, relacionais e lógicas
- **Estruturas de controle**: Condicionais (if) e loops (while)
- **Gerenciamento de memória**: Alocação (new) e desreferenciamento
- **Operações de I/O**: Leitura (read) e impressão (print)
- **Vinculação de variáveis**: Let com tipagem explícita

## Estrutura do Projeto

```
├── Datatypes.ml         # Definições dos tipos de dados e AST
├── test.ml              # Arquivo de testes (a ser implementado)
├── README.md            # Este arquivo
└── Trabalho_Semântica_2025_1.pdf  # Especificação do trabalho
```

## Componentes Principais

### Tipos de Dados (`Datatypes.ml`)

#### Operadores Binários (`bop`)
- **Aritméticos**: `Sum`, `Sub`, `Mul`, `Div`
- **Relacionais**: `Eq`, `Neq`, `Lt`, `Gt`
- **Lógicos**: `And`, `Or`

#### Sistema de Tipos (`tipo`)
- `TyInt`: Números inteiros
- `TyBool`: Valores booleanos
- `TyRef of tipo`: Referências para outros tipos
- `TyUnit`: Tipo unitário

#### Expressões (`expr`)
- `Num of int`: Literais numéricos
- `Bool of bool`: Literais booleanos
- `Id of string`: Identificadores de variáveis
- `If of expr * expr * expr`: Expressões condicionais
- `Binop of bop * expr * expr`: Operações binárias
- `Wh of expr * expr`: Loops while
- `Asg of expr * expr`: Atribuições
- `Let of string * tipo * expr * expr`: Vinculação de variáveis com tipo
- `New of expr`: Alocação de referências
- `Deref of expr`: Desreferenciamento
- `Unit`: Valor unitário
- `Seq of expr * expr`: Sequenciamento de expressões
- `Read`: Leitura de entrada
- `Print of expr`: Impressão de saída

## Exemplo de Uso

O arquivo `Datatypes.ml` inclui um exemplo de programa que calcula o fatorial de um número:

```ocaml
let x: int = read() in 
let z: ref int = new x in 
let y: ref int = new 1 in 
(while (!z > 0) (
       y := !y * !z;
       z := !z - 1);
print (!y))
```

Este programa:
1. Lê um número da entrada
2. Cria referências para o número lido e para o acumulador (inicializado com 1)
3. Executa um loop que multiplica o acumulador pelo contador e decrementa o contador
4. Imprime o resultado final (fatorial)

## Como Executar

### Pré-requisitos
- OCaml instalado no sistema
- Compilador OCaml (ocamlc ou ocamlopt)

### Compilação
```bash
ocamlc -o semantica Datatypes.ml
```

### Execução
```bash
./semantica
```

## Status do Desenvolvimento

- [x] Definição dos tipos de dados básicos
- [x] Implementação da AST (Abstract Syntax Tree)
- [x] Exemplo de programa (cálculo de fatorial)
- [ ] Implementação do avaliador/interpretador
- [ ] Sistema de tipos
- [ ] Testes unitários
- [ ] Documentação completa

## Referências

- Especificação completa do trabalho: `Trabalho_Semântica_2025_1.pdf`
- Disciplina: Semântica Formal - UFRGS
- Semestre: 2025/1

## Autor

Desenvolvido como parte dos requisitos da disciplina de Semântica Formal na Universidade Federal do Rio Grande do Sul (UFRGS).

---

**Nota**: Este é um projeto acadêmico em desenvolvimento. Consulte a especificação oficial para requisitos detalhados e critérios de avaliação.