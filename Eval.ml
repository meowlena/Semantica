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
exception StuckExpression of string

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
}

(* ===== FUNÇÕES AUXILIARES ===== *)

(* Verifica se uma expressão é um valor (forma normal) *)
let is_value = function
  | Num _ | Bool _ | Unit -> true
  | _ -> false

(* Converte uma expressão que é valor para o tipo valor *)
let expr_to_valor = function
  | Num n -> VInt n
  | Bool b -> VBool b
  | Unit -> VUnit
  | _ -> failwith "Expressão não é um valor"

(* Converte um valor para uma expressão *)
let valor_to_expr = function
  | VInt n -> Num n
  | VBool b -> Bool b
  | VUnit -> Unit
  | VRef addr -> Id ("__ref_" ^ string_of_int addr)  (* Usar ID temporário para refs *)

(* Busca variável no ambiente *)
let rec buscar_variavel nome env =
  match env with
  | [] -> failwith ("Variável não encontrada: " ^ nome)
  | (n, v) :: resto ->
      if n = nome then v
      else buscar_variavel nome resto

(* Converte um valor para string legível *)
let string_of_valor = function
  | VInt n -> "VInt " ^ string_of_int n
  | VBool b -> "VBool " ^ string_of_bool b
  | VRef addr -> "VRef " ^ string_of_int addr
  | VUnit -> "VUnit"

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
  | Num _ | Bool _ | Unit -> 
      raise (StuckExpression "Expressão já é um valor")
  
  (* VARIÁVEIS: substituição por valor do ambiente *)
  | Id nome ->
      (* Caso especial para referências temporárias *)
      if String.length nome > 6 && String.sub nome 0 6 = "__ref_" then
        let addr = int_of_string (String.sub nome 6 (String.length nome - 6)) in
        raise (StuckExpression ("REF_VALUE:" ^ string_of_int addr))
      else
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
      (* Caso especial para referências temporárias *)
      (match expr_valor with
      | Id ref_name when String.length ref_name > 6 && String.sub ref_name 0 6 = "__ref_" ->
          let addr = int_of_string (String.sub ref_name 6 (String.length ref_name - 6)) in
          let valor = VRef addr in
          let novo_env = (nome, valor) :: estado.env in
          let estado_com_var = { estado with env = novo_env } in
          (expr_corpo, estado_com_var)
      | _ ->
          if not (is_value expr_valor) then
            (* Reduz a expressão de valor *)
            let (expr_valor', estado') = step expr_valor estado in
            (Let(nome, tipo, expr_valor', expr_corpo), estado')
          else
            (* Valor pronto: faz a substituição *)
            let valor = expr_to_valor expr_valor in
            let novo_env = (nome, valor) :: estado.env in
            let estado_com_var = { estado with env = novo_env } in
            (expr_corpo, estado_com_var))
  
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
      (* NEW aloca um valor na memória e retorna uma referência para ele.
         É a única operação que modifica o estado da memória durante a criação.
         
         Fluxo: new expr → aloca expr na memória → retorna referência temporária
         Exemplo: new 42 → cria endereço 0 na memória → retorna Id("__ref_0")
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
          env = estado.env;           (* Ambiente permanece igual *)
          mem = nova_memoria;         (* Memória com novo valor *)
          next_addr = estado.next_addr + 1;  (* Próximo endereço livre *)
        } in
        
        (* Retorna uma referência temporária para o valor alocado *)
        (* Esta referência será processada pelo DEREF e ASG *)
        (Id ("__ref_" ^ string_of_int endereco), novo_estado)
  
  (* DEREF - Desreferenciamento (!expr) *)
  | Deref(expr) ->
      (* O desreferenciamento tem dois casos principais:
         1. Referências temporárias (criadas pelo NEW)
         2. Referências normais (variáveis que contêm VRef) *)
      
      (match expr with
      | Id ref_name when String.length ref_name > 6 && String.sub ref_name 0 6 = "__ref_" ->
          (* CASO 1: REFERÊNCIA TEMPORÁRIA *)
          (* Este é um identificador especial criado internamente pelo NEW.
             Formato: "__ref_N" onde N é o endereço na memória.
             
             Por exemplo: new 42 cria Id("__ref_0")
             Quando fazemos !(new 42), chegamos aqui com ref_name = "__ref_0"
          *)
          
          (* Extrai o endereço do nome temporário *)
          let addr = int_of_string (String.sub ref_name 6 (String.length ref_name - 6)) in
          
          (* Busca diretamente na memória usando o endereço *)
          let valor_armazenado = List.assoc addr estado.mem in
          
          (* Retorna o valor encontrado na memória *)
          (valor_to_expr valor_armazenado, estado)
          
      | _ ->
          (* CASO 2: EXPRESSÃO NORMAL (pode ser variável ou expressão complexa) *)
          
          if not (is_value expr) then
            (* A expressão ainda não foi reduzida a um valor.
               Por exemplo: !(if true then r else s)
               Primeiro precisamos reduzir o IF para obter a referência. *)
            let (expr', estado') = step expr estado in
            (Deref(expr'), estado')
            
          else
            (* A expressão já é um valor - deve ser uma referência *)
            let valor = expr_to_valor expr in
            (match valor with
            | VRef endereco ->
                (* É uma referência válida: busca o valor na memória *)
                let valor_armazenado = List.assoc endereco estado.mem in
                (valor_to_expr valor_armazenado, estado)
                
            | _ ->
                (* Não é uma referência: erro de tipo *)
                (* Por exemplo: !42, !true, !() são todos inválidos *)
                raise (TiposIncompativeis "Desreferenciamento requer uma referência")))
  
  (* ASSIGN - Atribuição (ref := valor) *)
  | Asg(expr_ref, expr_valor) ->
      (* A atribuição tem dois casos principais, similar ao DEREF:
         1. Referências temporárias (ex: (new 42) := 100)
         2. Referências normais (ex: r := 100, onde r é uma variável)
         
         Ambos os operandos precisam ser reduzidos a valores antes da atribuição.
         Ordem de avaliação: left-to-right (primeiro ref, depois valor)
      *)
      
      (match expr_ref with
      | Id ref_name when String.length ref_name > 6 && String.sub ref_name 0 6 = "__ref_" ->
          (* CASO 1: REFERÊNCIA TEMPORÁRIA *)
          (* Formato: "__ref_N" := valor
             Exemplo: (new 42) := 100 
             O NEW criou Id("__ref_0"), então temos "__ref_0" := 100
          *)
          
          if not (is_value expr_valor) then
            (* O valor ainda não foi reduzido. 
               Exemplo: r := (10 + 5)
               Primeiro reduzimos (10 + 5) para 15 *)
            let (expr_valor', estado') = step expr_valor estado in
            (Asg(expr_ref, expr_valor'), estado')
            
          else
            (* Ambos estão prontos: ref é temporária, valor é final *)
            
            (* Extrai o endereço da referência temporária *)
            let addr = int_of_string (String.sub ref_name 6 (String.length ref_name - 6)) in
            
            (* Converte o valor para o tipo interno *)
            let novo_valor = expr_to_valor expr_valor in
            
            (* Atualiza a memória: substitui o valor no endereço *)
            let nova_memoria = List.map (fun (a, v) -> 
              if a = addr then (a, novo_valor) else (a, v)
            ) estado.mem in
            
            (* Retorna () e o novo estado da memória *)
            let novo_estado = { estado with mem = nova_memoria } in
            (Unit, novo_estado)
            
      | _ ->
          (* CASO 2: EXPRESSÃO NORMAL (variável ou expressão complexa) *)
          
          if not (is_value expr_ref) then
            (* A referência ainda não foi reduzida a um valor.
               Exemplo: (if cond then r1 else r2) := 100
               Primeiro reduzimos o IF para obter a referência *)
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
            let ref_val = expr_to_valor expr_ref in
            let novo_valor = expr_to_valor expr_valor in
            
            (match ref_val with
            | VRef endereco ->
                (* É uma referência válida: atualiza a memória *)
                let nova_memoria = List.map (fun (a, v) -> 
                  if a = endereco then (a, novo_valor) else (a, v)
                ) estado.mem in
                let novo_estado = { estado with mem = nova_memoria } in
                (Unit, novo_estado)
                
            | _ ->
                (* Não é uma referência: erro de tipo *)
                (* Exemplos inválidos: 42 := 100, true := false, () := 10 *)
                raise (TiposIncompativeis "Atribuição requer uma referência")))
  
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
      print_string "> ";
      flush stdout;
      let linha = read_line () in
      (try
        let numero = int_of_string (String.trim linha) in
        (Num numero, estado)
      with
      | Failure _ ->
          failwith ("Entrada inválida: esperado um número, recebido '" ^ linha ^ "'"))
  
  (* WHILE *)
  | Wh(cond_expr, body_expr) ->
      (* While é açúcar sintático para if *)
      (If(cond_expr, Seq(body_expr, Wh(cond_expr, body_expr)), Unit), estado)
  
  (* FOR *)
  | For(var_name, start_expr, end_expr, body_expr) ->
      if not (is_value start_expr) then
        let (start_expr', estado') = step start_expr estado in
        (For(var_name, start_expr', end_expr, body_expr), estado')
      else if not (is_value end_expr) then
        let (end_expr', estado') = step end_expr estado in
        (For(var_name, start_expr, end_expr', body_expr), estado')
      else
        (* Desugaring para let + while usando referência interna *)
        (match (start_expr, end_expr) with
        | (Num start_int, Num end_int) ->
            (* 
              for i = start to end do body
              ≡ 
              let __counter = new start in
              while (!__counter <= end) do (
                let i = !__counter in body;
                __counter := !__counter + 1
              )
            *)
            let counter_name = "__counter_" ^ var_name in
            let ref_expr = New(start_expr) in
            let counter_deref = Deref(Id counter_name) in
            let cond = Binop(Lt, counter_deref, Binop(Sum, end_expr, Num 1)) in
            let body_with_var = Let(var_name, TyInt, counter_deref, body_expr) in
            let increment = Asg(Id counter_name, Binop(Sum, counter_deref, Num 1)) in
            let while_body = Seq(body_with_var, increment) in
            (Let(counter_name, TyRef TyInt, ref_expr, Wh(cond, while_body)), estado)
        | _ ->
            raise (TiposIncompativeis "For loop requer limites inteiros"))

(* ===== FUNÇÃO EVAL USANDO SMALL-STEP ===== *)

(* eval : expr -> estado -> (valor * estado)
   
   IMPLEMENTA A EXECUÇÃO COMPLETA SMALL-STEP
   
   Esta função executa repetidamente a função `step` até que a expressão
   seja reduzida a um valor (forma normal). Coordena com `step` para:
   - Manter consistência do estado da memória
   - Tratar casos especiais de referências temporárias
   - Garantir execução de efeitos colaterais (print, assign)
   
   Fluxo de execução:
   1. Verifica se a expressão já é um valor final (Num, Bool, Unit)
   2. Se não, aplica um passo de redução via `step`
   3. Trata exceções especiais para referências
   4. Repete até atingir forma normal
*)
let rec eval expr estado =
  (* DEBUG: Log da expressão sendo avaliada (descomente se necessário) *)
  (* Printf.printf "EVAL: %s\n" (string_of_expr expr); *)
  
  match expr with
  (* VALORES FINAIS: Não precisam mais redução *)
  | Num _ | Bool _ | Unit -> 
      (* Expressão já é um valor - conversão direta para tipo valor *)
      (expr_to_valor expr, estado)
  
  (* EXPRESSÕES COMPLEXAS: Precisam redução step-by-step *)
  | _ ->
    try
      (* PASSO 1: Tenta aplicar uma única redução small-step *)
      let (expr', estado') = step expr estado in
      
      (* PASSO 2: Recursão - continua reduzindo até atingir valor final *)
      (* Esta é a essência do small-step: redução iterativa *)
      eval expr' estado'
      
    with
    | StuckExpression msg ->
        (* TRATAMENTO DE CASOS ESPECIAIS *)
        (* Algumas operações (como criação de referências) requerem 
           coordenação especial entre step e eval via exceções *)
        
        (* Analisa a mensagem de exceção para determinar o tratamento *)
        (match msg with
        | s when String.length s > 10 && String.sub s 0 10 = "REF_VALUE:" ->
            (* CASO ESPECIAL: Referência temporária *)
            (* Quando uma referência temporária (__ref_N) é encontrada,
               extraímos o endereço e retornamos como VRef *)
            let addr = int_of_string (String.sub s 10 (String.length s - 10)) in
            (VRef addr, estado)
            
        | _ ->
            (* OUTROS CASOS *)
            (* Verifica se a expressão atual já é um valor que não foi
               reconhecido no pattern matching inicial *)
            if is_value expr then
              (* Conversão direta para valor *)
              (expr_to_valor expr, estado)
            else
              (* Erro real - expressão não pode ser reduzida *)
              failwith ("Expressão travada: " ^ msg))

(* ===== ESTADO INICIAL ===== *)
let estado_inicial = {
  env = [];
  mem = [];
  next_addr = 0;
}
