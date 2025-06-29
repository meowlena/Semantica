(* =====================================================
   AVALIADOR PARA A LINGUAGEM FUNCIONAL COM REFERÊNCIAS
   ===================================================== *)

(* Importa os tipos de expressões (AST) definidos em Datatypes.ml *)
open Datatypes

(* ===== EXCEPTIONS DO AVALIADOR ===== *)
exception DivisaoPorZero
exception TiposIncompativeis of string

(* ===== TIPOS SEMÂNTICOS ===== *)

(* Equivalente ao l das especificações da linguagem *)
(* Representa endereços de memória onde valores são armazenados *)

(* Valores computados pelo avaliador (semântica)
   Diferente das expressões (sintaxe), estes representam resultados *)
type valor = 
  | VInt of int      (* Números inteiros: 42, -5, 0 *)
  | VBool of bool    (* Valores booleanos: true, false *)
  | VRef of int      (* Referências: endereços na memória *)
  | VUnit            (* Valor unit: resultado de operações sem retorno *)

(* ===== ESTRUTURAS DO ESTADO DE EXECUÇÃO ===== *)

(* AMBIENTE: mapeia nomes de variáveis para seus valores
   Exemplo: [("x", VInt 10); ("y", VBool true)]
   Representa: x = 10, y = true *)
type ambiente = (string * valor) list 

(* MEMÓRIA: mapeia endereços para valores armazenados em referências
   Exemplo: [(0, VInt 42); (1, VBool false)]
   Representa: endereço 0 contém 42, endereço 1 contém false *)
type memoria = (int * valor) list

(* ESTADO: container completo do contexto de execução
   Mantém ambiente, memória e próximo endereço disponível *)
type estado = {
  env: ambiente;      (* ambiente atual de variáveis *)
  mem: memoria;       (* estado atual da memória, σ das especificações *)
  next_addr: int;     (* próximo endereço livre para novas referências, próx l *)
}

(* ===== FUNÇÕES AUXILIARES ===== *)

(* Adotei a abordagem de criar um ambiente. 
  * Contudo, no PDF é usado somente substituição textual.
  * A vantagem do ambiente é que ele exclui a necessidade de
  * varredura de expressões para encontrar variáveis.
  * Assim, o avaliador pode acessar diretamente o valor de uma variável
  * sem precisar percorrer toda a expressão.
  * Isso simplifica a implementação e melhora a eficiência.
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


(* ===== FUNÇÕES PARA OPERAÇÕES BINÁRIAS ===== *)

let aplicar_bop op v1 v2 = 
  match (op, v1, v2) with
  (* Operações aritméticas *)
  | (Sum, VInt n1, VInt n2) -> VInt (n1 + n2)
  | (Sub, VInt n1, VInt n2) -> VInt (n1 - n2)
  | (Mul, VInt n1, VInt n2) -> VInt (n1 * n2)
  | (Div, VInt n1, VInt n2) ->
    if n2 = 0 then 
      raise DivisaoPorZero
    else 
      VInt (n1 / n2)
      
  (* Operações de comparação *)
  | (Lt, VInt n1, VInt n2) -> VBool (n1 < n2)
  | (Gt, VInt n1, VInt n2) -> VBool (n1 > n2)
  | (Eq, VInt n1, VInt n2) -> VBool (n1 = n2)
  | (Neq, VInt n1, VInt n2) -> VBool (n1 <> n2)
  | (Eq, VBool b1, VBool b2) -> VBool (b1 = b2)
  | (Neq, VBool b1, VBool b2) -> VBool (b1 <> b2)
  | (Eq, VUnit, VUnit) -> VBool true
  | (Neq, VUnit, VUnit) -> VBool false
  
  (* Operações lógicas *)
  | (And, VBool b1, VBool b2) -> VBool (b1 && b2)
  | (Or, VBool b1, VBool b2) -> VBool (b1 || b2)
  
  | _ -> raise (TiposIncompativeis "Operação binária com tipos incompatíveis")

(* ===== FUNÇÃO PRINCIPAL DE AVALIAÇÃO ===== *)

(* eval : expr -> estado -> (valor * estado)
   
   PROPÓSITO:
   Executa uma expressão no contexto de um estado, retornando
   o valor computado e o novo estado (possivelmente modificado).
   
   PARÂMETROS:
   - expr: expressão a ser avaliada (do tipo definido em Datatypes.ml)
   - estado: contexto atual (ambiente + memória + endereços)
   
   RETORNO:
   - tupla (valor, novo_estado)
   
   CASOS IMPLEMENTADOS:
   - Num n: retorna VInt n (números literais)
   - Bool b: retorna VBool b (booleanos literais)  
   - Unit: retorna VUnit (valor unit)
   - Binop: operações aritméticas (Sum, Sub, Mul, Div), 
            comparações (Lt, Gt, Eq, Neq), e lógicas (And, Or)
   - If: expressões condicionais (if-then-else)
   
   CASOS PENDENTES:
   - Let: declaração de variáveis
   - Id: acesso a variáveis
   - New: criação de referências
   - Deref: desreferenciamento
   - Asg: atribuição a referências
   - Seq: sequenciamento
   - Wh: loops while
   - Print/Read: I/O básico
*)



let rec eval expr estado =
  match expr with
  (* LITERAIS: valores que se avaliam para si mesmos *)
  | Num n -> 
      (* Números inteiros: 42 → VInt 42 *)
      (VInt n, estado)
      
  | Bool b -> 
      (* Booleanos: true → VBool true *)
      (VBool b, estado)
      
  | Unit -> 
      (* Unit: () → VUnit *)
      (VUnit, estado)

  (* VARIÁVEIS *)
  | Id nome ->
      (* Acessa uma variável no ambiente: x → valor de x *)
      let valor = buscar_variavel nome estado.env in
      (valor, estado)

  | Let(nome, tipo, expr_valor, expr_corpo) ->
      (* Declara variável: let x: tipo = expr_valor in expr_corpo *)
      (* 1. Avalia a expressão de valor *)
      let (valor, estado1) = eval expr_valor estado in
      
      (* 2. Adiciona a variável ao ambiente *)
      let novo_env = (nome, valor) :: estado1.env in
      let estado_com_variavel = { estado1 with env = novo_env } in
      
      (* 3. Avalia o corpo da expressão no novo ambiente *)
      eval expr_corpo estado_com_variavel
      
  | Binop(op, e1, e2) -> 
      (* OPERAÇÕES BINÁRIAS: avaliar operandos e aplicar operação *)
      (match op with
       | And ->
           (* Tratamento de curto-circuito para AND *)
           let (v1, s1) = eval e1 estado in
           (match v1 with
            | VBool false -> (VBool false, s1)  (* Curto-circuito: se e1 é falso, não avalia e2 *)
            | VBool true -> eval e2 s1          (* Só avalia e2 se e1 é verdadeiro *)
            | _ -> raise (TiposIncompativeis "Operador AND requer operandos booleanos"))
       
       | Or ->
           (* Tratamento de curto-circuito para OR *)
           let (v1, s1) = eval e1 estado in
           (match v1 with
            | VBool true -> (VBool true, s1)   (* Curto-circuito: se e1 é verdadeiro, não avalia e2 *)
            | VBool false -> eval e2 s1        (* Só avalia e2 se e1 é falso *)
            | _ -> raise (TiposIncompativeis "Operador OR requer operandos booleanos"))
       
       | _ ->
           (* Para outras operações: avalia ambos os lados e aplica a operação *)
           let (valor1, estado1) = eval e1 estado in
           let (valor2, estado2) = eval e2 estado1 in
           let resultado = aplicar_bop op valor1 valor2 in
           (resultado, estado2))
          
  | If(cond, then_expr, else_expr) ->
      (* CONDICIONAL: if cond then then_expr else else_expr *)
      (* Verifica se a condição é booleana *)
      let (cond_val, estado1) = eval cond estado in
      (match cond_val with
      | VBool true -> 
          (* VERIFICAÇÃO DE TIPO: calcula o tipo do ramo else também para garantir consistência *)
          let (then_val, then_estado) = eval then_expr estado1 in
          (* No caso de curto-circuito, ainda avaliamos o else apenas para verificação de tipo *)
          let (else_val, _) = eval else_expr estado1 in
          if mesmo_tipo then_val else_val then
            (* Se os tipos são iguais, retorna o valor do ramo then *)
            (then_val, then_estado)
          else
            (* Se os tipos são diferentes, sinaliza erro *)
            raise (TiposIncompativeis 
                   ("Tipos inconsistentes nos ramos do IF: " ^ 
                    tipo_de_valor then_val ^ " e " ^ 
                    tipo_de_valor else_val))
      | VBool false -> 
          (* VERIFICAÇÃO DE TIPO: calcula o tipo do ramo then também para garantir consistência *)
          (* No caso de curto-circuito, ainda avaliamos o then apenas para verificação de tipo *)
          let (then_val, _) = eval then_expr estado1 in
          let (else_val, else_estado) = eval else_expr estado1 in
          if mesmo_tipo then_val else_val then
            (* Se os tipos são iguais, retorna o valor do ramo else *)
            (else_val, else_estado)
          else
            (* Se os tipos são diferentes, sinaliza erro *)
            raise (TiposIncompativeis 
                   ("Tipos inconsistentes nos ramos do IF: " ^ 
                    tipo_de_valor then_val ^ " e " ^ 
                    tipo_de_valor else_val))
      | _ -> 
          (* Erro se a condição não for booleana *)
          raise (TiposIncompativeis "Condição do IF deve ser booleana"))
  
  (* CASOS NÃO IMPLEMENTADOS: New, Deref, Asg, Wh, Seq, Print, Read *)
  | New _ -> failwith "New não implementado ainda"
  | Deref _ -> failwith "Deref não implementado ainda"  
  | Asg (_, _) -> failwith "Asg não implementado ainda"
  | Wh (_, _) -> failwith "Wh não implementado ainda"
  | Seq (_, _) -> failwith "Seq não implementado ainda"
  | Print _ -> failwith "Print não implementado ainda"
  | Read -> failwith "Read não implementado ainda"

(* ===== ESTADO INICIAL ===== *)

(* Estado vazio para começar a execução *)
let estado_inicial = {
  env = [];          (* nenhuma variável definida *)
  mem = [];          (* memória vazia *)
  next_addr = 0;     (* primeiro endereço será 0 *)
}

(* ===== EXPORTANDO ELEMENTOS PARA USO EXTERNO ===== *)
(* Exportação de tipos, exceções e funções para que possam ser usados em outros módulos *)

(* ===== NOTA SOBRE O USO DE IA ===== *)
(*
   NOTA: Foi utilizada Inteligência Artificial (GitHub Copilot) para auxiliar na:
   - Geração da documentação deste módulo
   - Criação do Makefile e scripts de compilação
   - Elaboração dos scripts de build multiplataforma (Windows/Unix)
   - Elaboração dos testes (Test.ml)
   
   O código lógico do avaliador foi implementado sem assistência direta de IA,
   seguindo as especificações formais do trabalho.
*)

(* ===== FIM DO ARQUIVO ===== *)
