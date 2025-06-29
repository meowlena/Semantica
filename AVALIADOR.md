# Documentação do Avaliador (Eval.ml)

## Visão Geral

O arquivo `Eval.ml` implementa um **interpretador small-step** para uma linguagem funcional com referências. O avaliador segue a semântica operacional especificada no trabalho, executando expressões passo a passo.

## Arquitetura

### Tipos Fundamentais

#### 1. `valor` - Valores Computados
```ocaml
type valor = 
  | VInt of int      (* Números inteiros *)
  | VBool of bool    (* Valores booleanos *)
  | VRef of int      (* Referências (endereços de memória) *)
  | VUnit            (* Valor unit *)
```

**Propósito**: Representa os valores que podem ser computados pelo avaliador. Estes são os "resultados finais" das expressões.

**Diferença de `expr`**: While `expr` (em Datatypes.ml) representa a **sintaxe** (como o código é escrito), `valor` representa a **semântica** (o que o código significa quando executado).

#### 2. `ambiente` - Contexto de Variáveis
```ocaml
type ambiente = (string * valor) list
```

**Propósito**: Mapeia nomes de variáveis para seus valores atuais.

**Exemplo**: `[("x", VInt 10); ("y", VBool true)]` significa:
- Variável `x` tem valor `10`
- Variável `y` tem valor `true`

#### 3. `memoria` - Estado da Memória
```ocaml
type memoria = (int * valor) list
```

**Propósito**: Mapeia endereços de memória para valores armazenados em referências.

**Exemplo**: `[(0, VInt 42); (1, VBool false)]` significa:
- Endereço `0` contém o valor `42`
- Endereço `1` contém o valor `false`

#### 4. `estado` - Contexto Completo
```ocaml
type estado = {
  env: ambiente;      (* ambiente atual *)
  mem: memoria;       (* memória atual *)
  next_addr: int;     (* próximo endereço livre *)
}
```

**Propósito**: Encapsula todo o contexto necessário para executar um programa.

## Função Principal: `eval`

### Assinatura
```ocaml
eval : expr -> estado -> (valor * estado)
```

### Comportamento
- **Entrada**: Uma expressão (`expr`) e um estado atual
- **Saída**: Uma tupla com o valor computado e o novo estado

### Casos Implementados

#### Literais (Valores Primitivos)
- `Num n`: Retorna `(VInt n, estado)` - números se avaliam para si mesmos
- `Bool b`: Retorna `(VBool b, estado)` - booleanos se avaliam para si mesmos  
- `Unit`: Retorna `(VUnit, estado)` - unit se avalia para VUnit

### Casos Pendentes

#### Operações Aritméticas/Lógicas
- `Binop(op, e1, e2)`: Avaliar `e1` e `e2`, aplicar operação `op`

#### Gerenciamento de Variáveis
- `Let(x, e1, e2)`: Avaliar `e1`, adicionar `x` ao ambiente, avaliar `e2`
- `Id x`: Buscar valor de `x` no ambiente

#### Operações com Referências
- `New e`: Avaliar `e`, alocar na memória, retornar referência
- `Deref e`: Avaliar `e` (deve ser referência), buscar valor na memória
- `Asg(e1, e2)`: Avaliar `e1` (referência) e `e2` (valor), atualizar memória

#### Controle de Fluxo
- `If(e1, e2, e3)`: Avaliar `e1`, escolher `e2` ou `e3` baseado no resultado
- `Wh(e1, e2)`: Loop while - repetir `e2` enquanto `e1` for verdadeiro
- `Seq(e1, e2)`: Avaliar `e1`, depois `e2`, retornar resultado de `e2`

#### I/O Básico
- `Print e`: Avaliar `e`, imprimir resultado, retornar unit
- `Read`: Ler entrada do usuário, retornar como inteiro

## Estado Inicial

```ocaml
let estado_inicial = {
  env = [];          (* nenhuma variável *)
  mem = [];          (* memória vazia *)
  next_addr = 0;     (* primeiro endereço será 0 *)
}
```

## Testes

O arquivo inclui uma bateria de testes que pode ser executada com:
```bash
ocamlc datatypes.ml eval.ml -o avaliador
./avaliador
```

### Testes Atuais
- Avaliação de números literais
- Avaliação de valores booleanos
- Avaliação de unit

## Próximos Passos

### 1. Implementar Operações Binárias
Adicionar suporte para `+`, `-`, `*`, `/`, `=`, `<`, etc.

### 2. Implementar Variáveis
Adicionar `Let` e `Id` para declaração e uso de variáveis.

### 3. Implementar Referências
Adicionar `New`, `Deref`, e `Asg` para operações de memória.

### 4. Implementar Controle de Fluxo
Adicionar `If`, `Wh`, e `Seq`.

### 5. Implementar I/O
Adicionar `Print` e `Read`.

## Exemplo de Uso

```ocaml
(* Avaliar expressão simples *)
let resultado = eval (Num 42) estado_inicial
(* resultado = (VInt 42, estado_inicial) *)

(* Avaliar expressão booleana *)
let resultado2 = eval (Bool true) estado_inicial  
(* resultado2 = (VBool true, estado_inicial) *)
```

## Conexão com a Especificação

O avaliador implementa as regras da semântica operacional definida no trabalho:
- **T-Num**: `n ⇓ VInt n`
- **T-Bool**: `b ⇓ VBool b`  
- **T-Unit**: `() ⇓ VUnit`

Cada caso do `match` corresponde a uma regra da semântica formal.
