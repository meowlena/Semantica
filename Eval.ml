(* =====================================================
   AVALIADOR SMALL-STEP PARA A LINGUAGEM L2
   ===================================================== *)

(* Este módulo implementa o avaliador small-step para a linguagem L2 conforme especificação formal.
   
   RELAÇÃO COM A ESPECIFICAÇÃO:
   - A linguagem L2 estende L1 com referências (new, !, :=)
   - Implementa semântica operacional SMALL-STEP: (e, σ) → (e', σ')
   - Mantém estado da memória para referências mutáveis
   - Usa ambiente para variáveis (equivalente à substituição textual da spec)
   - Executa passos pequenos até atingir um valor (forma normal)
*)

open Datatypes

(* ===== EXCEPTIONS DO AVALIADOR ===== *)
exception DivisaoPorZero
exception TiposIncompativeis of string


(* ===== TIPOS SEMÂNTICOS ===== *)
type valor = 
  | VInt of int      (* Números inteiros: n ∈ ℤ *)
  | VBool of bool    (* Valores booleanos: true, false *)
  | VRef of int      (* Localizações/Referências: l ∈ Loc *)
  | VUnit            (* Valor unit: () *)

type ambiente = (string * valor) list 
type memoria = (int * valor) list

type estado = {
  env: ambiente;      (* ρ: ambiente atual de variáveis *)
  mem: memoria;       (* σ: estado atual da memória *)
  next_addr: int;     (* próximo endereço livre *)
  input_buffer: int list; (* buffer de entradas simuladas para read *)
}

(* ===== FUNÇÕES AUXILIARES ===== *)

(* Verifica se uma expressão é um valor (forma normal) *)
let is_value = function
  | Num _ | Bool _ | Unit | Ref _ -> true
  | _ -> false

(* Converte uma expressão que é valor para o tipo valor *)
let expr_to_valor = function
  | Num n -> VInt n
  | Bool b -> VBool b
  | Unit -> VUnit
  | Ref addr -> VRef addr
  | _ -> raise (TiposIncompativeis "Expressão não é um valor")

(* Converte um valor para uma expressão *)
let valor_to_expr = function
  | VInt n -> Num n
  | VBool b -> Bool b
  | VUnit -> Unit
  | VRef addr -> Ref addr

(* Busca variável no ambiente *)
let rec buscar_variavel nome env =
  match env with
  | [] -> raise (TiposIncompativeis ("Variável não encontrada: " ^ nome))
  | (nome_var, valor_var) :: resto ->
      if nome_var = nome then valor_var
      else buscar_variavel nome resto

(* Converte um valor para string legível *)
let string_of_valor = function
  | VInt n -> "VInt " ^ string_of_int n
  | VBool b -> "VBool " ^ string_of_bool b
  | VRef addr -> "VRef " ^ string_of_int addr
  | VUnit -> "VUnit"

(* Imprime o estado atual da memória *)
let print_memoria memoria =
  print_endline "=== ESTADO DA MEMÓRIA ===";
  if memoria = [] then
    print_endline "  (memória vazia)"
  else
    List.iter (fun (endereco, valor) ->
      Printf.printf "  [%d] -> %s\n" endereco (string_of_valor valor)
    ) memoria;
  print_endline "=========================="

(* Imprime o ambiente atual *)
let print_ambiente ambiente =
  print_endline "=== AMBIENTE ===";
  if ambiente = [] then
    print_endline "  (ambiente vazia)"
  else
    List.iter (fun (nome, valor) ->
      Printf.printf "  %s -> %s\n" nome (string_of_valor valor)
    ) ambiente;
  print_endline "================"

(* Imprime o buffer de entrada atual *)
let print_input_buffer buffer =
  print_endline "=== BUFFER DE ENTRADA ===";
  if buffer = [] then
    print_endline "  (buffer vazio)"
  else
    List.iteri (fun indice entrada ->
      Printf.printf "  [%d] -> %d\n" indice entrada
    ) buffer;
  print_endline "========================="

(* Aplicação de operações binárias *)
let aplicar_bop op v1 v2 = 
  match (op, v1, v2) with
  (* OPERAÇÕES ARITMÉTICAS *)
  | (Sum, VInt n1, VInt n2) -> VInt (n1 + n2)
  | (Sub, VInt n1, VInt n2) -> VInt (n1 - n2)
  | (Mul, VInt n1, VInt n2) -> VInt (n1 * n2)
  | (Div, VInt n1, VInt n2) ->
      if n2 = 0 then raise DivisaoPorZero
      else VInt (n1 / n2)
      
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

(* ===== SEMÂNTICA SMALL-STEP ===== *)

(* step : expr -> estado -> (expr * estado)
   
   IMPLEMENTA A RELAÇÃO: (e, σ) → (e', σ')
   
   Faz um único passo de redução conforme as regras small-step do PDF.
*)
let rec step expr estado =
  match expr with
  
  (* VALORES: não reduzem mais (forma normal) *)
  | Num _ | Bool _ | Unit | Ref _ -> 
      raise (TiposIncompativeis "Expressão já é um valor")
  
  (* VARIÁVEIS: substituição por valor do ambiente *)
  | Id nome ->
      let valor = buscar_variavel nome estado.env in
      (valor_to_expr valor, estado)
  
  (* OPERAÇÕES BINÁRIAS *)
  | Binop(op, e1, e2) ->
      (match op with
      | And ->
          if not (is_value e1) then
            let (e1', estado') = step e1 estado in
            (Binop(op, e1', e2), estado')
          else
            (match e1 with
            | Bool false -> (Bool false, estado)  (* Curto-circuito *)
            | Bool true -> (e2, estado)           (* Avalia segundo operando *)
            | _ -> raise (TiposIncompativeis "Operador AND requer operandos booleanos"))
      
      | Or ->
          if not (is_value e1) then
            let (e1', estado') = step e1 estado in
            (Binop(op, e1', e2), estado')
          else
            (match e1 with
            | Bool true -> (Bool true, estado)   (* Curto-circuito *)
            | Bool false -> (e2, estado)         (* Avalia segundo operando *)
            | _ -> raise (TiposIncompativeis "Operador OR requer operandos booleanos"))
      
      | _ ->
          if not (is_value e1) then
            (* Reduz o primeiro operando *)
            let (e1', estado') = step e1 estado in
            (Binop(op, e1', e2), estado')
          else if not (is_value e2) then
            (* Reduz o segundo operando *)
            let (e2', estado') = step e2 estado in
            (Binop(op, e1, e2'), estado')
          else
            (* Ambos são valores: aplica a operação *)
            let v1 = expr_to_valor e1 in
            let v2 = expr_to_valor e2 in
            let resultado = aplicar_bop op v1 v2 in
            (valor_to_expr resultado, estado))
  
  (* IF-THEN-ELSE *)
  | If(cond, then_expr, else_expr) ->
      if not (is_value cond) then
        (* Reduz a condição *)
        let (cond', estado') = step cond estado in
        (If(cond', then_expr, else_expr), estado')
      else
        (* Condição é valor: escolhe o ramo *)
        (match cond with
        | Bool true -> (then_expr, estado)
        | Bool false -> (else_expr, estado)
        | _ -> raise (TiposIncompativeis "Condição do IF deve ser booleana"))
  
  (* LET *)
  | Let(nome, tipo, expr_valor, expr_corpo) ->
      if not (is_value expr_valor) then
        (* Reduz a expressão de valor *)
        let (expr_valor', estado') = step expr_valor estado in
        (Let(nome, tipo, expr_valor', expr_corpo), estado')
      else
        (* Valor pronto: faz a substituição *)
        let valor = expr_to_valor expr_valor in
        let novo_env = (nome, valor) :: estado.env in
        let estado_com_var = { estado with env = novo_env } in
        (expr_corpo, estado_com_var)
  
  (* SEQUENCIAMENTO *)
  | Seq(e1, e2) ->
      if not (is_value e1) then
        (* Reduz a primeira expressão *)
        let (e1', estado') = step e1 estado in
        (Seq(e1', e2), estado')
      else
        (* Primeira expressão é valor: descarta e vai para a segunda *)
        (e2, estado)
  
  (* NEW - Criação de referências (new expr) *)
  | New(expr) ->
      (* NEW aloca um valor na memória e retorna uma referência direta.
         
         Fluxo: new expr → aloca expr na memória → retorna Ref endereco
         Exemplo: new 42 → cria endereço 0 na memória → retorna Ref 0
      *)
      
      if not (is_value expr) then
        (* A expressão ainda não foi reduzida a um valor.
           Exemplo: new (5 + 10)
           Primeiro reduzimos (5 + 10) para 15, depois alocamos 15 na memória *)
        let (expr', estado') = step expr estado in
        (New(expr'), estado')
        
      else
        (* A expressão é um valor: podemos alocar na memória *)
        
        (* Converte a expressão para o tipo valor interno *)
        let valor = expr_to_valor expr in
        
        (* Obtém o próximo endereço livre *)
        let endereco = estado.next_addr in
        
        (* Adiciona o valor à memória no novo endereço *)
        let nova_memoria = (endereco, valor) :: estado.mem in
        
        (* Atualiza o estado: nova memória + incrementa próximo endereço *)
        let novo_estado = {
          env = estado.env;                     (* Ambiente permanece igual *)
          mem = nova_memoria;                   (* Memória com novo valor *)
          next_addr = estado.next_addr + 1;     (* Próximo endereço livre *)
          input_buffer = estado.input_buffer;   (* Buffer permanece igual *)
        } in
        
        (* Retorna uma referência direta (valor) *)
        (Ref endereco, novo_estado)
  
  (* DEREF - Desreferenciamento (!expr) *)
  | Deref(expr) ->
      if not (is_value expr) then
        (* A expressão ainda não foi reduzida a um valor.
           Exemplo: !(if true then r else s)
           Primeiro precisamos reduzir a expressão para obter a referência. *)
        let (expr', estado') = step expr estado in
        (Deref(expr'), estado')
      else
        (* A expressão já é um valor - deve ser uma referência *)
        (match expr with
        | Ref endereco ->
            (* É uma referência: busca o valor na memória *)
            let valor_armazenado = List.assoc endereco estado.mem in
            (valor_to_expr valor_armazenado, estado)
        | _ ->
            (* Não é uma referência: erro de tipo *)
            (* Por exemplo: !42, !true, !() são todos inválidos *)
            raise (TiposIncompativeis "Desreferenciamento requer uma referência"))
  
  (* ASSIGN - Atribuição (ref := valor) *)
  | Asg(expr_ref, expr_valor) ->
      (* Ordem de avaliação: left-to-right (primeiro ref, depois valor) *)
      
      if not (is_value expr_ref) then
        (* A referência ainda não foi reduzida a um valor.
           Exemplo: (if cond then r1 else r2) := 100
           Primeiro reduzimos o lado esquerdo para obter a referência *)
        let (expr_ref', estado') = step expr_ref estado in
        (Asg(expr_ref', expr_valor), estado')
        
      else if not (is_value expr_valor) then
        (* A referência está pronta, mas o valor não.
           Exemplo: r := (5 + 10)
           Reduzimos o valor mantendo a referência fixa *)
        let (expr_valor', estado') = step expr_valor estado in
        (Asg(expr_ref, expr_valor'), estado')
        
      else
        (* Ambos são valores: executa a atribuição *)
        (match expr_ref with
        | Ref endereco ->
            (* É uma referência: atualiza a memória *)
            let novo_valor = expr_to_valor expr_valor in
            let nova_memoria = List.map (fun (endereco_mem, valor_mem) -> 
              if endereco_mem = endereco then (endereco_mem, novo_valor) else (endereco_mem, valor_mem)
            ) estado.mem in
            let novo_estado = { estado with mem = nova_memoria } in
            (Unit, novo_estado)
            
        | _ ->
            (* Não é uma referência: erro de tipo *)
            (* Exemplos inválidos: 42 := 100, true := false, () := 10 *)
            raise (TiposIncompativeis "Atribuição requer uma referência"))
  
  (* PRINT *)
  | Print(expr) ->
      if not (is_value expr) then
        (* Reduz a expressão *)
        let (expr', estado') = step expr estado in
        (Print(expr'), estado')
      else
        (* Expressão é valor: imprime *)
        let valor = expr_to_valor expr in
        let string_valor = 
          match valor with
          | VInt n -> string_of_int n
          | VBool true -> "true"
          | VBool false -> "false"
          | VUnit -> "()"
          | VRef addr -> "ref@" ^ string_of_int addr
        in
        print_endline string_valor;
        (Unit, estado)
  
  (* READ *)
  | Read ->
      (* Usa buffer de entradas simuladas ao invés de input interativo *)
      (match estado.input_buffer with
      | [] -> 
          (* Buffer vazio: retorna 0 como valor padrão *)
          (Num 0, estado)
      | primeiro :: resto ->
          (* Consome a primeira entrada do buffer *)
          let novo_estado = { estado with input_buffer = resto } in
          (Num primeiro, novo_estado))
  
  (* WHILE *)
  | Wh(cond_expr, body_expr) ->
      (* While é açúcar sintático para if *)
      (If(cond_expr, Seq(body_expr, Wh(cond_expr, body_expr)), Unit), estado)
  
  (* FOR *)
  (* SINTAXE: For(var_name, start_expr, end_expr, body_expr)
     EXEMPLO: For("i", Num 1, Num 5, Print(Id "i"))  (* imprime 1,2,3,4,5 *)
     EXEMPLO: For("j", Num 0, Num 3, Print(Binop(Mul, Id "j", Num 10)))  (* imprime 0,10,20,30 *)
  *)
  | For(var_name, start_expr, end_expr, body_expr) ->
      if not (is_value start_expr) then
        let (start_expr', estado') = step start_expr estado in
        (For(var_name, start_expr', end_expr, body_expr), estado')
      else if not (is_value end_expr) then
        let (end_expr', estado') = step end_expr estado in
        (For(var_name, start_expr, end_expr', body_expr), estado')
      else
        (* Desugaring para let + while usando referência *)
        (match (start_expr, end_expr) with
        | (Num start_int, Num end_int) ->
            (* 
              for i = start to end do body
              ≡ 
              let counter = new start in
              while (!counter <= end) do (
                let i = !counter in (
                  body;
                  counter := !counter + 1
                )
              )
            *)
            let counter_name = "counter" in
            let ref_expr = New(start_expr) in
            let counter_ref = Id counter_name in
            let counter_deref = Deref(counter_ref) in
            let cond = Binop(Lt, counter_deref, Binop(Sum, end_expr, Num 1)) in
            let body_with_var = Let(var_name, TyInt, counter_deref, body_expr) in
            let increment = Asg(counter_ref, Binop(Sum, counter_deref, Num 1)) in
            let while_body = Let(var_name, TyInt, counter_deref, Seq(body_expr, increment)) in
            (Let(counter_name, TyRef TyInt, ref_expr, Wh(cond, while_body)), estado)
        | _ ->
            raise (TiposIncompativeis "For loop requer limites inteiros"))

(* ===== FUNÇÃO EVAL USANDO SMALL-STEP ===== *)

(* eval : expr -> estado -> (valor * estado)
   
   IMPLEMENTA A EXECUÇÃO COMPLETA SMALL-STEP
   
   Esta função executa repetidamente a função `step` até que a expressão
   seja reduzida a um valor (forma normal). É a implementação pura do
   small-step: redução iterativa até atingir forma normal.
*)
let rec eval expr estado =
  (* Verifica se já é um valor final *)
  if is_value expr then
    (expr_to_valor expr, estado)
  else
    (* Aplica um passo small-step e continua a avaliação *)
    let (expr', estado') = step expr estado in
    eval expr' estado'

(* ===== ESTADO INICIAL ===== *)
let estado_inicial = {
  env = [];
  mem = [];
  next_addr = 0;
  input_buffer = [];
}

(* Função auxiliar para criar estado com entradas simuladas *)
let estado_com_entradas entradas = {
  env = [];
  mem = [];
  next_addr = 0;
  input_buffer = entradas;
}

(* Imprime o estado completo (ambiente + memória + buffer) *)
let print_estado estado =
  print_endline "\n### ESTADO ATUAL ###";
  print_ambiente estado.env;
  print_memoria estado.mem;
  print_input_buffer estado.input_buffer;
  Printf.printf "Próximo endereço livre: %d\n" estado.next_addr;
  print_endline "##################\n"
