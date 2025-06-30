(* =====================================================
   AVALIADOR PARA A LINGUAGEM FUNCIONAL COM REFERÊNCIAS L2
   ===================================================== *)

(* Este módulo implementa o avaliador para a linguagem L2 conforme especificação formal.
   
   RELAÇÃO COM A ESPECIFICAÇÃO:
   - A linguagem L2 estende L1 com referências (new, !, :=)
   - Implementa semântica operacional big-step: (e, σ) ⇒ (v, σ')
   - Mantém estado da memória para referências mutáveis
   - Usa ambiente para variáveis (equivalente à substituição textual da spec)
   
   CONSTRUTOS IMPLEMENTADOS (conforme PDF):
   - Literais: números, booleanos, unit
   - Operações: aritméticas (+, -, *, /), comparações (<, >, =, ≠), lógicas (∧, ∨)
   - Controle: if-then-else, while, sequenciamento (;)
   - Variáveis: let-in, identificadores
   - Referências: new, desreferenciamento (!), atribuição (:=)
   - I/O: print, read
   - For: implementado via desugaring para while
*)

(* Importa os tipos de expressões (AST) definidos em Datatypes.ml *)
open Datatypes

(* ===== EXCEPTIONS DO AVALIADOR ===== *)
exception DivisaoPorZero
exception TiposIncompativeis of string

(* ===== TIPOS SEMÂNTICOS (DOMÍNIOS DA ESPECIFICAÇÃO L2) ===== *)

(* LOCALIZAÇÕES (l ∈ Loc): 
   Endereços de memória onde valores são armazenados.
   Na especificação formal, representados como l, l', l1, l2, etc.
   Aqui implementamos como inteiros para simplicidade. *)

(* VALORES (v ∈ Values):
   Resultados da avaliação de expressões. Diferente das expressões (sintaxe),
   estes representam dados computados.
   
   Conforme L2 spec: Values = Int + Bool + Unit + Loc *)
type valor = 
  | VInt of int      (* Números inteiros: n ∈ ℤ *)
  | VBool of bool    (* Valores booleanos: true, false *)
  | VRef of int      (* Localizações/Referências: l ∈ Loc *)
  | VUnit            (* Valor unit: () *)

(* ===== ESTRUTURAS DO ESTADO DE EXECUÇÃO ===== *)

(* AMBIENTE (ρ ∈ Env): 
   Mapeia nomes de variáveis para seus valores.
   Na especificação formal seria representado por substituição textual,
   mas usamos ambiente para eficiência.
   
   Exemplo: ρ = [x ↦ 42, y ↦ true] *)
type ambiente = (string * valor) list 

(* MEMÓRIA (σ ∈ Store):
   Mapeia localizações para valores armazenados.
   Conforme L2 spec: σ: Loc ⇀ Values (função parcial)
   
   Exemplo: σ = [l₀ ↦ 42, l₁ ↦ false] *)
type memoria = (int * valor) list

(* ESTADO COMPLETO:
   Encapsula o contexto completo de execução.
   - env: ambiente de variáveis (ρ)
   - mem: memória de referências (σ)  
   - next_addr: próxima localização livre (implementação) *)
type estado = {
  env: ambiente;      (* ρ: ambiente atual de variáveis *)
  mem: memoria;       (* σ: estado atual da memória *)
  next_addr: int;     (* próximo endereço livre (não na spec formal) *)
}

(* ===== FUNÇÕES AUXILIARES (OPERAÇÕES SOBRE DOMÍNIOS) ===== *)

(* NOTA IMPORTANTE SOBRE AMBIENTE vs SUBSTITUIÇÃO:
   A especificação L2 usa substituição textual para variáveis: e[x ↦ v].
   
   Aqui adoptamos a abordagem de ambiente (ρ) por vantagens práticas:
   - Evita varredura sintática da expressão para substituir variáveis
   - Acesso direto ao valor de uma variável (O(n) vs O(tamanho_expressão))
   - Implementação mais limpa e eficiente
   - Comportamento semântico equivalente à substituição
   
   Equivalência: ρ(x) = v  ≡  e[x ↦ v] na posição de x
*)

(* ===== FUNÇÕES AUXILIARES PARA MANIPULAÇÃO DE TIPOS ===== *)

(* Função para verificar se dois valores são do mesmo tipo *)
let mesmo_tipo v1 v2 =
  match (v1, v2) with
  | (VInt _, VInt _) -> true
  | (VBool _, VBool _) -> true
  | (VRef _, VRef _) -> true
  | (VUnit, VUnit) -> true
  | _ -> false

(* Função para obter uma string representando o tipo de um valor *)
let tipo_de_valor = function
  | VInt _ -> "Int"
  | VBool _ -> "Bool"
  | VRef _ -> "Ref"
  | VUnit -> "Unit"

(* Função para imprimir valores de forma legível (útil para debug) *)
let string_of_valor = function
  | VInt n -> "VInt " ^ string_of_int n
  | VBool b -> "VBool " ^ string_of_bool b
  | VRef addr -> "VRef " ^ string_of_int addr
  | VUnit -> "VUnit"

(* Função auxiliar para buscar variável no ambiente *)
let rec buscar_variavel nome env =
  match env with
  | [] -> failwith ("Variável não encontrada: " ^ nome)
  | (n, v) :: resto ->
      if n = nome then v
      else buscar_variavel nome resto


(* ===== FUNÇÕES PARA OPERAÇÕES BINÁRIAS (SEMÂNTICA DOS OPERADORES) ===== *)

(* Implementa a semântica das operações binárias conforme L2 spec.
   
   PADRÃO GERAL:
   Para operador op: v₁ op v₂ = v₃ (se operação bem tipada)
   Levanta exceção TiposIncompativeis caso contrário *)

let aplicar_bop op v1 v2 = 
  match (op, v1, v2) with
  (* OPERAÇÕES ARITMÉTICAS: ℤ × ℤ → ℤ *)
  | (Sum, VInt n1, VInt n2) -> VInt (n1 + n2)    (* + *)
  | (Sub, VInt n1, VInt n2) -> VInt (n1 - n2)    (* - *)
  | (Mul, VInt n1, VInt n2) -> VInt (n1 * n2)    (* * *)
  | (Div, VInt n1, VInt n2) ->                   (* / *)
    if n2 = 0 then 
      raise DivisaoPorZero
    else 
      VInt (n1 / n2)
      
  (* OPERAÇÕES DE COMPARAÇÃO: ℤ × ℤ → Bool *)
  | (Lt, VInt n1, VInt n2) -> VBool (n1 < n2)    (* < *)
  | (Gt, VInt n1, VInt n2) -> VBool (n1 > n2)    (* > *)
  | (Eq, VInt n1, VInt n2) -> VBool (n1 = n2)    (* = para int *)
  | (Neq, VInt n1, VInt n2) -> VBool (n1 <> n2)  (* ≠ para int *)
  
  (* IGUALDADE PARA OUTROS TIPOS *)
  | (Eq, VBool b1, VBool b2) -> VBool (b1 = b2)  (* = para bool *)
  | (Neq, VBool b1, VBool b2) -> VBool (b1 <> b2)(* ≠ para bool *)
  | (Eq, VUnit, VUnit) -> VBool true             (* = para unit *)
  | (Neq, VUnit, VUnit) -> VBool false           (* ≠ para unit *)
  
  (* OPERAÇÕES LÓGICAS: Bool × Bool → Bool *)
  | (And, VBool b1, VBool b2) -> VBool (b1 && b2) (* ∧ *)
  | (Or, VBool b1, VBool b2) -> VBool (b1 || b2)  (* ∨ *)
  
  | _ -> raise (TiposIncompativeis "Operação binária com tipos incompatíveis")

(* ===== FUNÇÃO PRINCIPAL DE AVALIAÇÃO (SEMÂNTICA OPERACIONAL) ===== *)

(* eval : expr -> estado -> (valor * estado)
   
   IMPLEMENTA A RELAÇÃO: (e, σ) ⇒ (v, σ')
   
   Onde:
   - e ∈ Expr: expressão a ser avaliada
   - σ ∈ Store: estado inicial da memória  
   - v ∈ Values: valor resultante
   - σ' ∈ Store: estado final da memória
   
   INTERPRETAÇÃO:
   "A expressão e, avaliada no estado σ, produz o valor v e novo estado σ'"
   
   PROPRIEDADES MANTIDAS:
   - Determinismo: para cada (e, σ), existe único (v, σ') tal que (e, σ) ⇒ (v, σ')
   - Preservação de tipos: expressões bem tipadas não geram erros de tipo
   - Progresso: expressões bem tipadas sempre terminam ou geram erro explícito
   
   CASOS IMPLEMENTADOS:
   Todos os construtos da linguagem L2 conforme especificação formal.
*)



let rec eval expr estado =
  match expr with
  
  (* ===== REGRAS PARA LITERAIS (VALUES) ===== *)
  (* Conforme L2 spec: se e é um valor, então (e, σ) ⇒ (e, σ) *)
  
  | Num n -> 
      (* REGRA [NUM]: (n, σ) ⇒ (n, σ) 
         Números inteiros se avaliam para si mesmos sem modificar o estado *)
      (VInt n, estado)
      
  | Bool b -> 
      (* REGRA [BOOL]: (b, σ) ⇒ (b, σ)
         Booleanos se avaliam para si mesmos sem modificar o estado *)
      (VBool b, estado)
      
  | Unit -> 
      (* REGRA [UNIT]: ((), σ) ⇒ ((), σ)
         Unit se avalia para si mesmo sem modificar o estado *)
      (VUnit, estado)

  (* ===== REGRA PARA VARIÁVEIS ===== *)
  | Id nome ->
      (* REGRA [VAR]: Consulta ambiente para recuperar valor da variável
         Nota: A especificação L2 usa substituição textual, mas aqui usamos ambiente
         para maior eficiência. O comportamento semântico é equivalente. *)
      let valor = buscar_variavel nome estado.env in
      (valor, estado)

  (* ===== REGRA PARA DECLARAÇÃO DE VARIÁVEIS ===== *)
  | Let(nome, tipo, expr_valor, expr_corpo) ->
      (* REGRA [LET]: let x: τ = e1 in e2
         Implementação usando ambiente ao invés de substituição textual.
         
         Semântica formal:
         (e1, σ) ⇒ (v1, σ')
         (e2[x ↦ v1], σ') ⇒ (v2, σ'')
         ──────────────────────────────────
         (let x: τ = e1 in e2, σ) ⇒ (v2, σ'')
      *)
      
      (* 1. Avalia a expressão de valor *)
      let (valor, estado1) = eval expr_valor estado in
      
      (* 2. Adiciona a variável ao ambiente (equivalente à substituição) *)
      let novo_env = (nome, valor) :: estado1.env in
      let estado_com_variavel = { estado1 with env = novo_env } in
      
      (* 3. Avalia o corpo da expressão no novo ambiente *)
      eval expr_corpo estado_com_variavel
      
  (* ===== REGRAS PARA OPERAÇÕES BINÁRIAS ===== *)
  | Binop(op, e1, e2) -> 
      (* REGRAS [BINOP]: Operações binárias seguem o padrão:
         (e1, σ) ⇒ (v1, σ1)
         (e2, σ1) ⇒ (v2, σ2)
         v1 op v2 = v3
         ──────────────────────────
         (e1 op e2, σ) ⇒ (v3, σ2)
         
         Com exceção dos operadores de curto-circuito (AND, OR)
      *)
      (match op with
       | And ->
           (* REGRA [AND] com curto-circuito:
              Se e1 ⇒ false, então (e1 && e2) ⇒ false (sem avaliar e2)
              Se e1 ⇒ true, então (e1 && e2) ⇒ avalia e2 *)
           let (v1, s1) = eval e1 estado in
           (match v1 with
            | VBool false -> (VBool false, s1)  (* Curto-circuito: se e1 é falso, não avalia e2 *)
            | VBool true -> eval e2 s1          (* Avalia segundo operando *)
            | _ -> raise (TiposIncompativeis "Operador AND requer operandos booleanos"))
       
       | Or ->
           (* REGRA [OR] com curto-circuito:
              Se e1 ⇒ true, então (e1 || e2) ⇒ true (sem avaliar e2)
              Se e1 ⇒ false, então (e1 || e2) ⇒ avalia e2 *)
           let (v1, s1) = eval e1 estado in
           (match v1 with
            | VBool true -> (VBool true, s1)   (* Curto-circuito: se e1 é verdadeiro, não avalia e2 *)
            | VBool false -> eval e2 s1        (* Avalia segundo operando *)
            | _ -> raise (TiposIncompativeis "Operador OR requer operandos booleanos"))
       
       | _ ->
           (* Para outras operações: avalia ambos os operandos sequencialmente *)
           let (valor1, estado1) = eval e1 estado in
           let (valor2, estado2) = eval e2 estado1 in
           let resultado = aplicar_bop op valor1 valor2 in
           (resultado, estado2))
          
  (* ===== REGRA PARA CONDICIONAL ===== *)
  | If(cond, then_expr, else_expr) ->
      (* REGRA [IF]: if e0 then e1 else e2
         
         Caso 1 - Condição verdadeira:
         (e0, σ) ⇒ (true, σ')
         (e1, σ') ⇒ (v1, σ'')
         ──────────────────────────────────
         (if e0 then e1 else e2, σ) ⇒ (v1, σ'')
         
         Caso 2 - Condição falsa:
         (e0, σ) ⇒ (false, σ')
         (e2, σ') ⇒ (v2, σ'')
         ──────────────────────────────────
         (if e0 then e1 else e2, σ) ⇒ (v2, σ'')
      *)
      let (cond_val, estado1) = eval cond estado in
      (match cond_val with
      | VBool true -> 
          (* Avalia ramo then *)
          let (then_val, then_estado) = eval then_expr estado1 in
          (* Verificação de tipo: garante que ambos os ramos têm o mesmo tipo *)
          let (else_val, _) = eval else_expr estado1 in
          if mesmo_tipo then_val else_val then
            (then_val, then_estado)
          else
            raise (TiposIncompativeis 
                   ("Tipos inconsistentes nos ramos do IF: " ^ 
                    tipo_de_valor then_val ^ " e " ^ 
                    tipo_de_valor else_val))
      | VBool false -> 
          (* Avalia ramo else *)
          let (then_val, _) = eval then_expr estado1 in
          let (else_val, else_estado) = eval else_expr estado1 in
          if mesmo_tipo then_val else_val then
            (else_val, else_estado)
          else
            raise (TiposIncompativeis 
                   ("Tipos inconsistentes nos ramos do IF: " ^ 
                    tipo_de_valor then_val ^ " e " ^ 
                    tipo_de_valor else_val))
      | _ -> 
          raise (TiposIncompativeis "Condição do IF deve ser booleana"))
  
  (* ===== REGRA PARA SEQUENCIAMENTO ===== *)
  | Seq(e1, e2) ->
      (* REGRA [SEQ]: e1; e2
         (e1, σ) ⇒ (v1, σ')
         (e2, σ') ⇒ (v2, σ'')
         ─────────────────────
         (e1; e2, σ) ⇒ (v2, σ'')
         
         Executa e1, descarta seu valor, depois executa e2 *)
      let (_, estado1) = eval e1 estado in
      eval e2 estado1
  
  (* ===== REGRAS PARA REFERÊNCIAS ===== *)
  | New(expr) ->
      (* REGRA [NEW]: new e
         (e, σ) ⇒ (v, σ')
         l = proxima_localizacao(σ')
         ─────────────────────────────────
         (new e, σ) ⇒ (l, σ'[l ↦ v])
         
         Cria uma nova referência, armazena o valor na memória *)
      let (valor, estado1) = eval expr estado in
      let endereco = estado1.next_addr in
      let nova_memoria = (endereco, valor) :: estado1.mem in
      let novo_estado = {
        env = estado1.env;
        mem = nova_memoria;
        next_addr = endereco + 1;
      } in
      (VRef endereco, novo_estado)
  
  (* REGRA [DEREF]: !e (desreferenciamento) *)
  | Deref(expr) ->
      (* REGRA [DEREF]: !e
         (e, σ) ⇒ (l, σ')
         σ'(l) = v
         ───────────────────
         (!e, σ) ⇒ (v, σ')
         
         Obtém o valor armazenado no endereço referenciado *)
      let (valor, estado1) = eval expr estado in
      (match valor with
      | VRef endereco ->
          let rec buscar_na_memoria addr mem =
            match mem with
            | [] -> failwith ("Endereço inválido na memória: " ^ string_of_int addr)
            | (a, v) :: resto ->
                if a = addr then v
                else buscar_na_memoria addr resto
          in
          let valor_armazenado = buscar_na_memoria endereco estado1.mem in
          (valor_armazenado, estado1)
      | _ ->
          raise (TiposIncompativeis "Desreferenciamento requer uma referência"))
  
  (* REGRA [ASSIGN]: e1 := e2 (atribuição) *)
  | Asg(expr_ref, expr_valor) ->
      (* REGRA [ASSIGN]: e1 := e2
         (e1, σ) ⇒ (l, σ')
         (e2, σ') ⇒ (v, σ'')
         ─────────────────────────────
         (e1 := e2, σ) ⇒ ((), σ''[l ↦ v])
         
         Atualiza o valor armazenado na referência *)
      let (ref_val, estado1) = eval expr_ref estado in
      (match ref_val with
      | VRef endereco ->
          let (novo_valor, estado2) = eval expr_valor estado1 in
          let rec atualizar_memoria addr novo_val mem =
            match mem with
            | [] -> failwith ("Endereço inválido na atribuição: " ^ string_of_int addr)
            | (a, v) :: resto ->
                if a = addr then (a, novo_val) :: resto
                else (a, v) :: (atualizar_memoria addr novo_val resto)
          in
          let nova_memoria = atualizar_memoria endereco novo_valor estado2.mem in
          let novo_estado = { estado2 with mem = nova_memoria } in
          (VUnit, novo_estado)
      | _ ->
          raise (TiposIncompativeis "Atribuição requer uma referência como destino"))
  (* ===== REGRA PARA WHILE ===== *)
  | Wh(cond_expr, body_expr) ->
      (* REGRA [WHILE]: while e1 do e2
         
         Caso 1 - Condição verdadeira:
         (e1, σ) ⇒ (true, σ')
         (e2, σ') ⇒ (v, σ'')
         (while e1 do e2, σ'') ⇒ ((), σ''')
         ─────────────────────────────────────
         (while e1 do e2, σ) ⇒ ((), σ''')
         
         Caso 2 - Condição falsa:
         (e1, σ) ⇒ (false, σ')
         ──────────────────────────
         (while e1 do e2, σ) ⇒ ((), σ')
      *)
      let rec loop_while estado_atual =
        let (cond_val, estado_pos_cond) = eval cond_expr estado_atual in
        (match cond_val with
        | VBool true ->
            (* Executa corpo e continua o loop *)
            let (_, estado_pos_body) = eval body_expr estado_pos_cond in
            loop_while estado_pos_body
        | VBool false ->
            (* Termina o loop, retorna VUnit *)
            (VUnit, estado_pos_cond)
        | _ ->
            raise (TiposIncompativeis "Condição do while deve ser booleana"))
      in
      loop_while estado
  
  (* ===== REGRAS PARA I/O ===== *)
  | Print(expr) ->
      (* REGRA [PRINT]: print e
         (e, σ) ⇒ (v, σ')
         output(v)
         ─────────────────────
         (print e, σ) ⇒ ((), σ')
         
         Imprime o valor e retorna unit *)
      let (valor, estado1) = eval expr estado in
      let string_valor = 
        match valor with
        | VInt n -> string_of_int n
        | VBool true -> "true"
        | VBool false -> "false"
        | VUnit -> "()"
        | VRef addr -> "ref@" ^ string_of_int addr
      in
      print_endline string_valor;
      (VUnit, estado1)
  
  | Read ->
      (* REGRA [READ]: read
         input() = v
         ─────────────────
         (read, σ) ⇒ (v, σ)
         
         Lê um valor da entrada padrão *)
      print_string "> ";
      flush stdout;
      let linha = read_line () in
      (try
        let numero = int_of_string (String.trim linha) in
        (VInt numero, estado)
      with
      | Failure _ ->
          failwith ("Entrada inválida: esperado um número, recebido '" ^ linha ^ "'"))

  (* ===== REGRA PARA FOR (DESUGARING) ===== *)
  | For(var_name, start_expr, end_expr, body_expr) ->
      (* REGRA [FOR]: for x = e1 to e2 do e3
         
         Implementação via desugaring (açúcar sintático):
         for x = e1 to e2 do e3  ≡  
         let x: ref int = new e1 in
         while (!x <= e2) do (
           e3;
           x := !x + 1
         )
         
         Esta abordagem reduz FOR a construtos já implementados (LET, NEW, WHILE),
         mantendo a semântica equivalente à especificação formal.
      *)
      
      (* 1. Avalia as expressões de limite *)
      let (start_val, estado1) = eval start_expr estado in
      let (end_val, estado2) = eval end_expr estado1 in
      
      (match (start_val, end_val) with
      | (VInt start_int, VInt end_int) ->
          (* 2. Cria uma referência para a variável do loop *)
          let next_addr = estado2.next_addr in
          let nova_memoria = (next_addr, VInt start_int) :: estado2.mem in
          let novo_ambiente = (var_name, VRef next_addr) :: estado2.env in
          let estado_com_var = {
            env = novo_ambiente;
            mem = nova_memoria;
            next_addr = next_addr + 1;
          } in
          
          (* 3. Implementa o loop usando a semântica de while *)
          let rec loop_for estado_atual =
            (match buscar_variavel var_name estado_atual.env with
            | VRef addr ->
                let valor_atual = List.assoc addr estado_atual.mem in
                (match valor_atual with
                | VInt i when i <= end_int ->
                    (* Executa corpo e incrementa variável *)
                    let (_, estado_pos_body) = eval body_expr estado_atual in
                    let nova_mem = List.map (fun (a, v) -> 
                      if a = addr then (a, VInt (i + 1)) else (a, v)
                    ) estado_pos_body.mem in
                    let estado_incrementado = { estado_pos_body with mem = nova_mem } in
                    loop_for estado_incrementado
                    
                | VInt _ ->
                    (* Condição falsa, termina o loop *)
                    let env_sem_var = List.filter (fun (n, _) -> n <> var_name) estado_atual.env in
                    (VUnit, { estado_atual with env = env_sem_var })
                    
                | _ -> failwith "Variável de loop corrompida")
            | _ -> failwith "Variável de loop deve ser uma referência")
          in
          loop_for estado_com_var
          
      | _ -> raise (TiposIncompativeis "For loop requer limites inteiros"))

(* ===== ESTADO INICIAL (CONFIGURAÇÃO INICIAL DO SISTEMA) ===== *)

(* Estado vazio para inicializar a execução de programas.
   
   Conforme L2 spec, um programa inicia com:
   - Ambiente vazio: ρ₀ = ∅ (nenhuma variável definida)
   - Memória vazia: σ₀ = ∅ (nenhuma localização alocada)
   - Próximo endereço: l₀ = 0 (primeira localização disponível)
   
   INVARIANTE: next_addr sempre aponta para a próxima localização livre *)
let estado_inicial = {
  env = [];          (* ρ₀ = ∅: nenhuma variável definida *)
  mem = [];          (* σ₀ = ∅: memória vazia *)
  next_addr = 0;     (* l₀ = 0: primeiro endereço será 0 *)
}

(* ===== INTERFACE PÚBLICA DO MÓDULO ===== *)
(* 
   Este módulo exporta:
   - Tipos: valor, ambiente, memoria, estado
   - Exceções: DivisaoPorZero, TiposIncompativeis  
   - Funções: eval, estado_inicial
   - Funções auxiliares: string_of_valor, buscar_variavel, aplicar_bop
   
   UTILIZAÇÃO TÍPICA:
   let (resultado, estado_final) = eval programa estado_inicial
*)

(* ===== NOTAS SOBRE IMPLEMENTAÇÃO E ESPECIFICAÇÃO FORMAL ===== *)
(*
   CORRESPONDÊNCIA COM L2 SPEC:
   
   1. SINTAXE: Definida em Datatypes.ml, corresponde às regras gramaticais do PDF
   
   2. SEMÂNTICA OPERACIONAL: Implementada neste arquivo usando big-step
      - Cada caso de 'eval' corresponde a uma regra de inferência
      - Formato: (e, σ) ⇒ (v, σ') onde e=expressão, σ=estado, v=valor
      
   3. DOMÍNIOS SEMÂNTICOS:
      - Values = Int + Bool + Unit + Loc (tipo 'valor')
      - Store = Loc ⇀ Values (tipo 'memoria') 
      - Env = Var → Values (tipo 'ambiente', substituição por eficiência)
      
   4. DIFERENÇAS DE IMPLEMENTAÇÃO:
      - Ambiente no lugar de substituição textual (equivalência semântica)
      - Inteiros para localizações (simplificação da implementação)
      - Verificação de tipos em tempo de execução (dynamic typing)
      - For implementado via desugaring (redução a construtos primitivos)
      
   5. PROPRIEDADES PRESERVADAS:
      - Determinismo da avaliação
      - Semântica das operações
      - Comportamento das referências e estado mutável
      - Controle de fluxo (if, while, sequenciamento)
*)

(* ===== NOTA SOBRE O USO DE IA ===== *)
(*
   DISCLAIMER: Foi utilizada Inteligência Artificial (GitHub Copilot) para auxiliar na:
   - Geração da documentação e comentários deste módulo
   - Criação do Makefile e scripts de compilação multiplataforma
   - Elaboração dos scripts de build (Windows/Unix/PowerShell/Batch)
   - Criação e estruturação dos testes automatizados (Test.ml)
   
   O código lógico do avaliador foi implementado manualmente seguindo as 
   especificações formais do trabalho, sem assistência direta de IA na lógica
   de avaliação das expressões.
   
   A documentação e comentários foram aprimorados com IA para melhor clareza
   e correspondência com a terminologia da especificação formal L2.
*)

(* ===== FIM DO ARQUIVO ===== *)
