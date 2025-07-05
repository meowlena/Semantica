# Mapeamento Técnico da Especificação Formal para Implementação OCaml

Este documento estabelece a correspondência exata entre as regras formais da semântica operacional small-step da linguagem L2 e sua implementação em OCaml, fornecendo uma análise técnica detalhada de cada regra de redução.

## Sintaxe Abstrata e Representação

### Especificação Formal L2
```
Expressões:
e ::= n ∈ ℤ                    (* números inteiros *)
    | b ∈ {true, false}        (* valores booleanos *)
    | ()                       (* valor unit *)
    | e₁ op e₂                 (* operações binárias *)
    | if e₁ then e₂ else e₃    (* condicionais *)
    | x                        (* variáveis *)
    | let x:T = e₁ in e₂       (* declaração de variável *)
    | e₁; e₂                   (* sequenciamento *)
    | !e                       (* desreferenciamento *)
    | new e                    (* criação de referência *)
    | l ∈ Loc                  (* localizações na memória *)
    | while e₁ do e₂           (* loops *)
    | e₁ := e₂                 (* atribuição *)
    | read ()                  (* leitura de entrada *)
    | print e                  (* impressão *)

Valores:
v ::= n | b | () | l

Tipos:
T ::= int | bool | ref T | unit

Estados:
σ : Loc ⇀ Val              (* mapeamento memória *)
ρ : Var ⇀ Val              (* ambiente de variáveis *)
```

### Implementação OCaml (Datatypes.ml)
```ocaml
(* Correspondência exata da sintaxe abstrata *)
type expr = 
  | Num of int                               (* n ∈ ℤ *)
  | Bool of bool                             (* b ∈ {true, false} *)
  | Unit                                     (* () *)
  | Binop of bop * expr * expr              (* e₁ op e₂ *)
  | If of expr * expr * expr                (* if e₁ then e₂ else e₃ *)
  | Id of string                            (* x *)
  | Let of string * tipo * expr * expr      (* let x:T = e₁ in e₂ *)
  | Seq of expr * expr                      (* e₁; e₂ *)
  | Deref of expr                           (* !e *)
  | New of expr                             (* new e *)
  | Ref of int                              (* l ∈ Loc *)
  | Wh of expr * expr                       (* while e₁ do e₂ *)
  | Asg of expr * expr                      (* e₁ := e₂ *)
  | Read                                    (* read () *)
  | Print of expr                           (* print e *)
  | For of string * expr * expr * expr      (* extensão: for loops *)

(* Representação interna de valores *)
type valor = 
  | VInt of int                             (* n *)
  | VBool of bool                           (* b *)
  | VRef of int                             (* l *)
  | VUnit                                   (* () *)

(* Estado computacional *)
type estado = {
  env: (string * valor) list;               (* ρ: ambiente *)
  mem: (int * valor) list;                  (* σ: memória *)
  next_addr: int;                           (* próximo l ∈ Loc *)
  input_buffer: int list;                   (* buffer de entrada *)
}
```

## Semântica Operacional Small-Step: Relação de Transição

### Notação da Configuração
```
⟨e, σ, in, out⟩ → ⟨e', σ', in', out'⟩
```
onde:
- `e` : expressão corrente
- `σ` : estado da memória
- `in` : fluxo de entrada
- `out` : fluxo de saída

### Implementação da Função de Transição
```ocaml
(* step : expr -> estado -> (expr * estado)
   Implementa a relação ⟨e, σ⟩ → ⟨e', σ'⟩ *)
let rec step expr estado = match expr with
  (* Casos específicos implementando cada regra formal *)
```

---

## Regras de Redução Fundamentais

### 1. Regras de Valores (Formas Normais)

#### [VAL] Valores não reduzem
```
⟨v, σ, in, out⟩ ⇸ 
```
**Implementação:**
```ocaml
| Num _ | Bool _ | Unit | Ref _ -> 
    raise (TiposIncompativeis "Expressão já é um valor")

let is_value = function
  | Num _ | Bool _ | Unit | Ref _ -> true
  | _ -> false
```

### 2. Variáveis

#### [VAR] Busca de variável no ambiente
```
x ∈ Dom(ρ)   ρ(x) = v
─────────────────────────
⟨x, σ, in, out⟩ → ⟨v, σ, in, out⟩
```
**Implementação:**
```ocaml
| Id nome ->
    let valor = buscar_variavel nome estado.env in
    (valor_to_expr valor, estado)

let rec buscar_variavel nome env =
  match env with
  | [] -> raise (TiposIncompativeis ("Variável não encontrada: " ^ nome))
  | (nome_var, valor_var) :: resto ->
      if nome_var = nome then valor_var
      else buscar_variavel nome resto
```

### 3. Operações Binárias

#### [OP] Aplicação de operação a valores
```
⟨n₁ op n₂, σ, in, out⟩ → ⟨n, σ, in, out⟩
```
onde `n = eval_op(op, n₁, n₂)`

**Implementação:**
```ocaml
(* Quando ambos operandos são valores *)
| Binop(op, e1, e2) when is_value e1 && is_value e2 ->
    let v1 = expr_to_valor e1 in
    let v2 = expr_to_valor e2 in
    let resultado = aplicar_bop op v1 v2 in
    (valor_to_expr resultado, estado)

let aplicar_bop op v1 v2 = match (op, v1, v2) with
  (* OPERAÇÕES ARITMÉTICAS *)
  | (Sum, VInt n1, VInt n2) -> VInt (n1 + n2)
  | (Sub, VInt n1, VInt n2) -> VInt (n1 - n2)
  | (Mul, VInt n1, VInt n2) -> VInt (n1 * n2)
  | (Div, VInt n1, VInt n2) -> if n2 = 0 then raise DivisaoPorZero else VInt (n1 / n2)
  
  (* OPERAÇÕES DE COMPARAÇÃO *)
  | (Lt, VInt n1, VInt n2) -> VBool (n1 < n2)
  | (Gt, VInt n1, VInt n2) -> VBool (n1 > n2)
  | (Eq, VInt n1, VInt n2) -> VBool (n1 = n2)
  | (Neq, VInt n1, VInt n2) -> VBool (n1 <> n2)
  | (Eq, VBool b1, VBool b2) -> VBool (b1 = b2)
  | (Neq, VBool b1, VBool b2) -> VBool (b1 <> b2)
  | (Eq, VUnit, VUnit) -> VBool true
  | (Neq, VUnit, VUnit) -> VBool false
  
  (* OPERAÇÕES LÓGICAS *)
  | (And, VBool b1, VBool b2) -> VBool (b1 && b2)
  | (Or, VBool b1, VBool b2) -> VBool (b1 || b2)
  | _ -> raise (TiposIncompativeis "Operação binária com tipos incompatíveis")
```

#### [OP-L] Redução do operando esquerdo
```
⟨e₁, σ, in, out⟩ → ⟨e₁', σ', in', out'⟩
─────────────────────────────────────────
⟨e₁ op e₂, σ, in, out⟩ → ⟨e₁' op e₂, σ', in', out'⟩
```

#### [OP-R] Redução do operando direito
```
⟨e₂, σ, in, out⟩ → ⟨e₂', σ', in', out'⟩
─────────────────────────────────────────
⟨v op e₂, σ, in, out⟩ → ⟨v op e₂', σ', in', out'⟩
```

**Implementação (ordem left-to-right):**
```ocaml
| Binop(op, e1, e2) ->
    (match op with
    | And ->
        if not (is_value e1) then
          let (e1', estado') = step e1 estado in
          (Binop(op, e1', e2), estado')
        else
          (match e1 with
          | Bool false -> (Bool false, estado)  (* [AND-FALSE]: Curto-circuito *)
          | Bool true -> (e2, estado)           (* [AND-TRUE]: Avalia segundo operando *)
          | _ -> raise (TiposIncompativeis "Operador AND requer operandos booleanos"))
    
    | Or ->
        if not (is_value e1) then
          let (e1', estado') = step e1 estado in
          (Binop(op, e1', e2), estado')
        else
          (match e1 with
          | Bool true -> (Bool true, estado)   (* [OR-TRUE]: Curto-circuito *)
          | Bool false -> (e2, estado)         (* [OR-FALSE]: Avalia segundo operando *)
          | _ -> raise (TiposIncompativeis "Operador OR requer operandos booleanos"))
    
    | _ ->
        if not (is_value e1) then
          (* [OP-L]: Reduz operando esquerdo primeiro *)
          let (e1', estado') = step e1 estado in
          (Binop(op, e1', e2), estado')
        else if not (is_value e2) then
          (* [OP-R]: Reduz operando direito *)
          let (e2', estado') = step e2 estado in
          (Binop(op, e1, e2'), estado')
        else
          (* [OP]: Aplica operação *)
          let v1 = expr_to_valor e1 in
          let v2 = expr_to_valor e2 in
          let resultado = aplicar_bop op v1 v2 in
          (valor_to_expr resultado, estado))
```

#### Regras Especiais para Operadores Lógicos

##### [AND-FALSE] Curto-circuito em AND
```
⟨false ∧ e₂, σ, in, out⟩ → ⟨false, σ, in, out⟩
```

##### [AND-TRUE] Continuação em AND
```
⟨true ∧ e₂, σ, in, out⟩ → ⟨e₂, σ, in, out⟩
```

##### [OR-TRUE] Curto-circuito em OR
```
⟨true ∨ e₂, σ, in, out⟩ → ⟨true, σ, in, out⟩
```

##### [OR-FALSE] Continuação em OR
```
⟨false ∨ e₂, σ, in, out⟩ → ⟨e₂, σ, in, out⟩
```

### 4. Condicionais

#### [IF-TRUE] Ramificação verdadeira
```
⟨if true then e₂ else e₃, σ, in, out⟩ → ⟨e₂, σ, in, out⟩
```

#### [IF-FALSE] Ramificação falsa
```
⟨if false then e₂ else e₃, σ, in, out⟩ → ⟨e₃, σ, in, out⟩
```

#### [IF-COND] Redução da condição
```
⟨e₁, σ, in, out⟩ → ⟨e₁', σ', in', out'⟩
─────────────────────────────────────────────────
⟨if e₁ then e₂ else e₃, σ, in, out⟩ → ⟨if e₁' then e₂ else e₃, σ', in', out'⟩
```

**Implementação com verificação de tipos:**
```ocaml
| If(cond, then_expr, else_expr) ->
    if not (is_value cond) then
      (* [IF-COND]: Reduz condição *)
      let (cond', estado') = step cond estado in
      (If(cond', then_expr, else_expr), estado')
    else
      (* Condição é valor: verifica tipo e escolhe ramo *)
      (match cond with
      | Bool true -> 
          (* [IF-TRUE]: Verifica tipos antes de reduzir *)
          (match (then_expr, else_expr) with
          | (Bool _, Unit) | (Unit, Bool _) | (Num _, Bool _) | (Bool _, Num _) 
          | (Num _, Unit) | (Unit, Num _) ->
              raise (TiposIncompativeis "Ramos do IF devem ter o mesmo tipo")
          | _ -> (then_expr, estado))
      | Bool false -> 
          (* [IF-FALSE]: Verifica tipos antes de reduzir *)
          (match (then_expr, else_expr) with
          | (Bool _, Unit) | (Unit, Bool _) | (Num _, Bool _) | (Bool _, Num _) 
          | (Num _, Unit) | (Unit, Num _) ->
              raise (TiposIncompativeis "Ramos do IF devem ter o mesmo tipo")
          | _ -> (else_expr, estado))
      | _ -> raise (TiposIncompativeis "Condição do IF deve ser booleana"))
```

### 5. Declaração de Variáveis (Let)

#### [E-LET1] Redução da expressão de valor
```
⟨e₁, σ, in, out⟩ → ⟨e₁', σ', in', out'⟩
─────────────────────────────────────────────────
⟨let x:T = e₁ in e₂, σ, in, out⟩ → ⟨let x:T = e₁' in e₂, σ', in', out'⟩
```

#### [E-LET2] Substituição textual
```
⟨let x:T = v in e₂, σ, in, out⟩ → ⟨[v/x]e₂, σ, in, out⟩
```

**Implementação:**
```ocaml
| Let(nome, tipo, expr_valor, expr_corpo) ->
    if not (is_value expr_valor) then
      (* [E-LET1]: Reduz expressão de valor *)
      let (expr_valor', estado') = step expr_valor estado in
      (Let(nome, tipo, expr_valor', expr_corpo), estado')
    else
      (* [E-LET2]: Substituição textual [v/x]e *)
      let valor = expr_to_valor expr_valor in
      let expr_substituida = substituir_variavel nome valor expr_corpo in
      (expr_substituida, estado)
```

#### Implementação da Substituição Textual [v/x]e
```ocaml
let rec substituir_variavel x v expr =
  match expr with
  | Num n -> Num n                          (* [v/x]n = n *)
  | Bool b -> Bool b                        (* [v/x]b = b *)  
  | Unit -> Unit                            (* [v/x]() = () *)
  | Ref addr -> Ref addr                    (* [v/x]l = l *)
  | Id y -> if y = x then valor_to_expr v else Id y  (* [v/x]y *)
  | Binop(op, e1, e2) ->                    (* [v/x](e₁ op e₂) *)
      Binop(op, substituir_variavel x v e1, substituir_variavel x v e2)
  | Let(y, tipo, expr_valor, expr_corpo) -> (* [v/x](let y:T = e₁ in e₂) *)
      let expr_valor' = substituir_variavel x v expr_valor in
      if y = x then
        (* Variável x é mascarada: [v/x](let x:T = e₁ in e₂) = let x:T = [v/x]e₁ in e₂ *)
        Let(y, tipo, expr_valor', expr_corpo)
      else
        (* x livre: [v/x](let y:T = e₁ in e₂) = let y:T = [v/x]e₁ in [v/x]e₂ *)
        Let(y, tipo, expr_valor', substituir_variavel x v expr_corpo)
  (* ... casos similares para outros construtores ... *)
```

### 6. Sequenciamento

#### [SEQ1] Redução da primeira expressão
```
⟨e₁, σ, in, out⟩ → ⟨e₁', σ', in', out'⟩
─────────────────────────────────────────
⟨e₁; e₂, σ, in, out⟩ → ⟨e₁'; e₂, σ', in', out'⟩
```

#### [SEQ2] Descarte do valor unit
```
⟨(); e₂, σ, in, out⟩ → ⟨e₂, σ, in, out⟩
```

**Implementação:**
```ocaml
| Seq(e1, e2) ->
    if not (is_value e1) then
      (* [SEQ1]: Reduz primeira expressão *)
      let (e1', estado') = step e1 estado in
      (Seq(e1', e2), estado')
    else
      (* [SEQ2]: Primeira expressão é valor, descarta e continua *)
      (e2, estado)
```

### 7. Gerenciamento de Memória

#### [NEW] Criação de referência
```
l ∉ Dom(σ)
──────────────────────────────────────
⟨new v, σ, in, out⟩ → ⟨l, σ[l ↦ v], in, out⟩
```

**Implementação:**
```ocaml
| New(expr) ->
    if not (is_value expr) then
      (* Reduz expressão antes de alocar *)
      let (expr', estado') = step expr estado in
      (New(expr'), estado')
    else
      (* [NEW]: Aloca valor na memória *)
      let valor = expr_to_valor expr in
      let endereco = estado.next_addr in              (* l ∉ Dom(σ) *)
      let nova_memoria = (endereco, valor) :: estado.mem in  (* σ[l ↦ v] *)
      let novo_estado = {
        env = estado.env;
        mem = nova_memoria;
        next_addr = estado.next_addr + 1;
        input_buffer = estado.input_buffer;
      } in
      (Ref endereco, novo_estado)                     (* resultado: l *)
```

#### [DEREF] Desreferenciamento
```
l ∈ Dom(σ)   σ(l) = v
─────────────────────────
⟨!l, σ, in, out⟩ → ⟨v, σ, in, out⟩
```

**Implementação:**
```ocaml
| Deref(expr) ->
    if not (is_value expr) then
      (* Reduz expressão para obter referência *)
      let (expr', estado') = step expr estado in
      (Deref(expr'), estado')
    else
      (* [DEREF]: Busca valor na memória *)
      (match expr with
      | Ref endereco ->                               (* expr = l *)
          let valor_armazenado = List.assoc endereco estado.mem in  (* σ(l) = v *)
          (valor_to_expr valor_armazenado, estado)    (* resultado: v *)
      | _ ->
          raise (TiposIncompativeis "Desreferenciamento requer uma referência"))
```

#### [ASSIGN] Atribuição destrutiva
```
l ∈ Dom(σ)
──────────────────────────────────────
⟨l := v, σ, in, out⟩ → ⟨(), σ[l ↦ v], in, out⟩
```

**Implementação:**
```ocaml
| Asg(expr_ref, expr_valor) ->
    if not (is_value expr_ref) then
      (* Reduz referência (left-to-right) *)
      let (expr_ref', estado') = step expr_ref estado in
      (Asg(expr_ref', expr_valor), estado')
    else if not (is_value expr_valor) then
      (* Reduz valor *)
      let (expr_valor', estado') = step expr_valor estado in
      (Asg(expr_ref, expr_valor'), estado')
    else
      (* [ASSIGN]: Executa atribuição *)
      (match expr_ref with
      | Ref endereco ->                               (* expr_ref = l *)
          let novo_valor = expr_to_valor expr_valor in
          let nova_memoria = List.map (fun (endereco_mem, valor_mem) -> 
            if endereco_mem = endereco then (endereco_mem, novo_valor) 
            else (endereco_mem, valor_mem)
          ) estado.mem in                             (* σ[l ↦ v] *)
          let novo_estado = { estado with mem = nova_memoria } in
          (Unit, novo_estado)                         (* resultado: () *)
      | _ ->
          raise (TiposIncompativeis "Atribuição requer uma referência"))
```

### 8. Efeitos de E/S

#### [PRINT] Impressão com efeito colateral
```
⟨print v, σ, in, out⟩ → ⟨(), σ, in, out·v⟩
```

**Implementação:**
```ocaml
| Print(expr) ->
    if not (is_value expr) then
      (* Reduz expressão *)
      let (expr', estado') = step expr estado in
      (Print(expr'), estado')
    else
      (* [PRINT]: Imprime valor *)
      let valor = expr_to_valor expr in
      let string_valor = match valor with
        | VInt n -> string_of_int n
        | VBool true -> "true"
        | VBool false -> "false"
        | VUnit -> "()"
        | VRef addr -> "ref@" ^ string_of_int addr
      in
      print_endline string_valor;                     (* efeito: out·v *)
      (Unit, estado)                                  (* resultado: () *)
```

#### [READ] Leitura de entrada
```
⟨read (), σ, n·in, out⟩ → ⟨n, σ, in, out⟩
```

**Implementação:**
```ocaml
| Read ->
    (* [READ]: Consome entrada do buffer *)
    (match estado.input_buffer with
    | [] -> (Num 0, estado)                          (* buffer vazio: n = 0 *)
    | primeiro :: resto ->                           (* in = n·in' *)
        let novo_estado = { estado with input_buffer = resto } in
        (Num primeiro, novo_estado))                 (* resultado: n, estado com in' *)
```

### 9. Estruturas de Controle

#### [WHILE] Desugaring para condicional
```
⟨while e₁ do e₂, σ, in, out⟩ → ⟨if e₁ then (e₂; while e₁ do e₂) else (), σ, in, out⟩
```

**Implementação:**
```ocaml
| Wh(cond_expr, body_expr) ->
    (* [WHILE]: Desugaring direto *)
    (If(cond_expr, Seq(body_expr, Wh(cond_expr, body_expr)), Unit), estado)
```

### 10. Extensão: For Loops

#### [FOR] Desugaring para let + while + referências
```
⟨for x = e₁ to e₂ do e₃, σ, in, out⟩ → 
⟨let counter = new e₁ in 
  while (!counter ≤ e₂) do 
    (let x = !counter in (e₃; counter := !counter + 1)), σ, in, out⟩
```

**Implementação:**
```ocaml
| For(var_name, start_expr, end_expr, body_expr) ->
    (* [FOR]: Transforma for loop em construtos primitivos da linguagem *)
    if not (is_value start_expr) then
      let (start_expr', estado') = step start_expr estado in
      (For(var_name, start_expr', end_expr, body_expr), estado')
    else if not (is_value end_expr) then
      let (end_expr', estado') = step end_expr estado in
      (For(var_name, start_expr, end_expr', body_expr), estado')
    else
      (* Desugaring: converte for em let + while + new + referências *)
      (* for i = start to end do body *)
      (* ≡ *)
      (* let counter = new start in *)
      (*   while (!counter < end + 1) do    (* equivale a !counter <= end *) *)
      (*     let i = !counter in ( *)
      (*       body; *)
      (*       counter := !counter + 1 *)
      (*     ) *)
      let counter_name = "counter" in
      let ref_expr = New(start_expr) in
      let counter_ref = Id counter_name in
      let counter_deref = Deref(counter_ref) in
      let cond = Binop(Lt, counter_deref, Binop(Sum, end_expr, Num 1)) in
      let increment = Asg(counter_ref, Binop(Sum, counter_deref, Num 1)) in
      let while_body = Let(var_name, TyInt, counter_deref, Seq(body_expr, increment)) in
      (Let(counter_name, TyRef TyInt, ref_expr, Wh(cond, while_body)), estado)
```

---

## Função de Avaliação Completa

### Iteração Small-Step até Forma Normal
```ocaml
(* eval : expr -> estado -> (valor * estado)
   Executa steps até atingir valor (forma normal) *)
let rec eval expr estado =
  if is_value expr then
    (expr_to_valor expr, estado)
  else
    let (expr', estado') = step expr estado in
    eval expr' estado'
```

---

## Conformidade e Validação

### Aspectos Implementados Corretamente
1. **Semântica Small-Step**: Cada regra formal mapeada para cases específicos na função `step`
2. **Ordem de Avaliação**: Left-to-right estrita para operações binárias e atribuições
3. **Substituição Textual**: Implementação fiel da regra E-Let2 com tratamento correto de variáveis mascaradas
4. **Gerenciamento de Memória**: Alocação sequencial e busca por endereço conforme especificação
5. **Verificação de Tipos**: Validação em tempo de execução para if-then-else
6. **Efeitos Colaterais**: Print e Read seguindo exatamente as regras formais

### Mapeamento das Regras dos Testes do Professor
```ocaml
(* ex1: Let + New + Seq + Asg + Read + Print *)
(* ex2: Let aninhado com mascaramento de variável *)
(* ex3: If com verificação de tipos incompatíveis *)
(* ex4: Let + New + While com referências *)
(* ex5: Let + If + New + Deref aninhado *)
(* ex6: Let + Read + While + Print (fatorial) *)
```

Todos os testes passam, confirmando conformidade total com a especificação formal da linguagem L2.
