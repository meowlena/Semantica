# GUIA DE REFERÊNCIA RÁPIDA - OCaml e Semântica Formal

## CONCEITOS BÁSICOS DE OCAML

### `let` - Vinculação de Valores
```ocaml
let x = 42                    (* valor simples *)
let soma x y = x + y          (* função *)
let rec fat n = if n <= 1 then 1 else n * fat (n-1) (* recursiva *)

(* let...in - escopo local *)
let resultado = 
  let x = 10 in
  let y = 20 in
  x + y
```

### Tipos Básicos
```ocaml
int       (* números inteiros: 42, -5 *)
bool      (* booleanos: true, false *)
string    (* strings: "texto" *)
unit      (* tipo unitário: () *)
```

### Pattern Matching
```ocaml
match expr with
| Caso1 -> resultado1
| Caso2 -> resultado2
| _ -> default
```

---

## TIPOS DA SUA LINGUAGEM

### `bop` - Operadores Binários
```ocaml
Sum, Sub, Mul, Div    (* +, -, *, / *)
Eq, Neq, Lt, Gt       (* =, ≠, <, > *)
And, Or               (* ∧, ∨ *)
```

### `tipo` - Sistema de Tipos
```ocaml
TyInt                 (* números inteiros *)
TyBool                (* booleanos *)
TyRef of tipo         (* referências: TyRef TyInt *)
TyUnit                (* tipo unitário *)
```

### `expr` - Expressões (AST)
```ocaml
Num of int            (* 42 *)
Bool of bool          (* true *)
Id of string          (* "x" *)
If of expr*expr*expr  (* if-then-else *)
Binop of bop*expr*expr (* operações binárias *)
Let of string*tipo*expr*expr (* let x: tipo = e1 in e2 *)
```

---

## OPERAÇÕES COM REFERÊNCIAS

### `New` - Criação
```ocaml
New (Num 42)          (* cria referência com valor 42 *)
New (Id "x")          (* cria referência com valor de x *)
```

### `Deref` - Leitura (!)
```ocaml
Deref (Id "counter")  (* lê valor de counter: !counter *)
```

### `Asg` - Escrita (:=)
```ocaml
Asg(Id "x", Num 10)   (* x := 10 *)
```

---

## ESTRUTURAS DE CONTROLE

### `If` - Condicional
```ocaml
If(condicao, entao, senao)
(* if condicao then entao else senao *)
```

### `Wh` - Loop While
```ocaml
Wh(condicao, corpo)
(* while condicao do corpo *)
```

### `Seq` - Sequenciamento
```ocaml
Seq(expr1, expr2)
(* expr1; expr2 *)
```

---

## EXEMPLO PRÁTICO

### Código na Sua Linguagem:
```
let x: int = read() in
let counter: ref int = new x in
while (!counter > 0) (
  counter := !counter - 1
);
print (!counter)
```

### Como AST:
```ocaml
Let("x", TyInt, Read,
  Let("counter", TyRef TyInt, New (Id "x"),
    Seq(
      Wh(Binop(Gt, Deref (Id "counter"), Num 0),
         Asg(Id "counter", Binop(Sub, Deref (Id "counter"), Num 1))),
      Print(Deref (Id "counter"))
    )
  )
)
```

---

## RESUMO RÁPIDO

| Conceito | OCaml | Sua Linguagem |
|----------|-------|---------------|
| Variável | `let x = 42` | `Let("x", TyInt, Num 42, ...)` |
| Função | `let f x = x + 1` | (não tem funções ainda) |
| Referência | `ref 42` | `New (Num 42)` |
| Leitura ref | `!x` | `Deref (Id "x")` |
| Escrita ref | `x := 10` | `Asg(Id "x", Num 10)` |
| Condicional | `if b then e1 else e2` | `If(b, e1, e2)` |
| Sequência | `e1; e2` | `Seq(e1, e2)` |

---

## PRÓXIMOS PASSOS

1. **Avaliador**: Função que executa a AST
2. **Sistema de tipos**: Verifica consistência
3. **Parser**: Converte texto em AST
4. **Testes**: Valida funcionamento

---

## DEBUGGING

### Para testar no OCaml:
```bash
ocamlc -c Datatypes.ml     # compila
ocaml                      # abre interpretador
#use "Datatypes.ml";;      # carrega arquivo
factorial_program;;        # mostra AST
```

### Verificar tipos:
```ocaml
#factorial_program;;       # mostra tipo e valor
```
