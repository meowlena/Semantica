(* =====================================================
   AVALIADOR PARA A LINGUAGEM FUNCIONAL COM REFERÊNCIAS
   ===================================================== *)

(* Importa os tipos de expressões (AST) definidos em Datatypes.ml *)
open Datatypes

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

(* Adotei a abordagem de criar um ambiente. 
  * Contudo, no PDF é usado somente substitução textual.
  * A vantagem do ambiente é que ele exclui a necessidade de
  * varredura de expressões para encontrar variáveis.
  * Assim, o avaliador pode acessar diretamente o valor de uma variável
  * sem precisar percorrer toda a expressão.
  * Isso simplifica a implementação e melhora a eficiência.
*)

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
   
   CASOS PENDENTES:
   - Binop: operações aritméticas e lógicas
   - Let: declaração de variáveis
   - Id: acesso a variáveis
   - New: criação de referências
   - Deref: desreferenciamento
   - Asg: atribuição a referências
   - Seq: sequenciamento
   - If: condicionais
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
      
  (* CASOS NÃO IMPLEMENTADOS *)
  | _ -> failwith "Construção não implementada ainda"

(* ===== ESTADO INICIAL E TESTES ===== *)

(* Estado vazio para começar a execução *)
let estado_inicial = {
  env = [];          (* nenhuma variável definida *)
  mem = [];          (* memória vazia *)
  next_addr = 0;     (* primeiro endereço será 0 *)
}

(* ===== FUNÇÕES AUXILIARES PARA TESTES ===== *)

(* Função para imprimir valores de forma legível *)
let string_of_valor = function
  | VInt n -> "VInt " ^ string_of_int n
  | VBool b -> "VBool " ^ string_of_bool b
  | VRef addr -> "VRef " ^ string_of_int addr
  | VUnit -> "VUnit"

(* Função para executar e imprimir resultado de um teste *)
let teste_eval expr nome =
  let (valor, novo_estado) = eval expr estado_inicial in
  Printf.printf "%s: %s\n" nome (string_of_valor valor)

(* ===== BATERIA DE TESTES BÁSICOS ===== *)

(* Testes dos casos já implementados *)
let () = 
  print_endline "=== TESTES DO AVALIADOR ===";
  teste_eval (Num 42) "Teste 1 (Num 42)";
  teste_eval (Bool true) "Teste 2 (Bool true)";
  teste_eval (Bool false) "Teste 3 (Bool false)";
  teste_eval Unit "Teste 4 (Unit)";
  print_endline "=== FIM DOS TESTES ==="

(* Definições para testes interativos *)
let teste1 = eval (Num 42) estado_inicial
let teste2 = eval (Bool true) estado_inicial
let teste3 = eval Unit estado_inicial

