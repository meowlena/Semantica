(* ===== DEFINIÇÕES DOS TIPOS DA LINGUAGEM ===== *)

(* Operadores binários suportados pela linguagem *)
type bop =  
  | Sum | Sub | Mul | Div   (* operações aritméticas: +, -, *, / *)
  | Eq  | Neq | Lt | Gt     (* operações relacionais: =, ≠, <, > *)
  | And | Or                (* operações lógicas: ∧, ∨ *) 

(* Sistema de tipos da linguagem *)
type tipo = 
  | TyInt                   (* números inteiros *)
  | TyBool                  (* valores booleanos *)
  | TyRef of tipo          (* referências (ponteiros) para outros tipos *)
  | TyUnit                 (* tipo unitário (equivalente ao void) *)
    
(* Árvore de Sintaxe Abstrata (AST) - todas as expressões possíveis *)
type expr = 
  | Num of int                        (* literais numéricos: 42, -5, 0 *)
  | Bool of bool                      (* literais booleanos: true, false *)
  | Id of string                      (* identificadores: x, y, counter *)
  | If of expr * expr * expr          (* condicionais: if e1 then e2 else e3 *)
  | Binop of bop * expr * expr        (* operações binárias: e1 + e2, e1 && e2 *)
  | Wh of expr * expr                 (* loops while: while e1 do e2 *)
  | Asg of expr * expr                (* atribuições: e1 := e2 *)
  | Let of string * tipo * expr * expr (* vinculação: let x: tipo = e1 in e2 *)
  | New of expr                       (* alocação de referência: new e *)
  | Deref of expr                     (* desreferenciamento: !e *)
  | Unit                              (* valor unitário: () *)
  | Seq of expr * expr                (* sequenciamento: e1; e2 *)
  | Read                              (* leitura da entrada padrão *)
  | Print of expr                     (* impressão na saída padrão *)
  
      

(* ===== EXEMPLO: PROGRAMA PARA CÁLCULO DE FATORIAL ===== *)

(*         
  Programa exemplo que demonstra o uso da linguagem.
  Calcula o fatorial de um número lido da entrada.
  
  Sintaxe equivalente em uma linguagem imperativa:
  
  let input_number: int = read() in 
  let counter: ref int = new input_number in 
  let accumulator: ref int = new 1 in 
  
  (while (!counter > 0) (
        accumulator := !accumulator * !counter;
        counter := !counter - 1);
  print (!accumulator))     
  
  Funcionamento:
  1. Lê um número da entrada
  2. Inicializa contador com o valor lido
  3. Inicializa acumulador com 1
  4. Loop: multiplica acumulador pelo contador e decrementa contador
  5. Imprime o resultado final (fatorial)
*)


(* ----- Componentes do Loop While ----- *)

(* Condição do while: counter > 0 *)
let while_condition = Binop(Gt, Deref (Id "counter"), Num 0)

(* Operação: accumulator := accumulator * counter *)
let update_accumulator = 
  Asg(Id "accumulator", 
    Binop(Mul, Deref (Id "accumulator"),
    Deref(Id "counter"))
  )

(* Operação: counter := counter - 1 *)
let decrement_counter = 
  Asg(Id "counter", 
  Binop(Sub, Deref (Id "counter"),
  Num 1))

(* Corpo do while: atualiza acumulador; decrementa contador *)
let while_body = Seq(update_accumulator, decrement_counter) 

(* Loop while completo: while (counter > 0) do body *)
let factorial_loop = Wh(while_condition, while_body)

(* ----- Finalização do Programa ----- *)

(* Impressão do resultado: print(!accumulator) *)
let print_result = Print(Deref (Id "accumulator"))

(* Sequência: executa loop e depois imprime resultado *)
let loop_and_print = Seq(factorial_loop, print_result)
    
(* ----- Programa Principal ----- *)

(* 
  Programa completo para cálculo de fatorial:
  - Declara variável input_number e lê valor da entrada
  - Declara referência counter inicializada com input_number  
  - Declara referência accumulator inicializada com 1
  - Executa o loop de cálculo e imprime o resultado
*)
let factorial_program = 
  Let("input_number", TyInt, Read, 
    Let("counter", TyRef TyInt, New (Id "input_number"), 
        Let("accumulator", TyRef TyInt, New (Num 1),
            loop_and_print)))

(* ===== INFORMAÇÕES SOBRE O PROGRAMA ===== *)

(*
  Para testar este programa:
  1. Compile: ocamlc -c Datatypes.ml
  2. No interpretador OCaml: #use "Datatypes.ml";;
  3. O programa está disponível na variável: factorial_program
  
  Exemplo de uso:
  - Para calcular 5! (fatorial de 5), o programa lerá 5 e retornará 120
  - Para calcular 0!, o programa retornará 1 (caso base)
  - Para calcular 3!, o programa retornará 6 (3 * 2 * 1)
  
  Estrutura da AST:
  O programa demonstra o uso de:
  - Tipos: TyInt, TyRef TyInt
  - Expressões: Let, New, Deref, Binop, Wh, Asg, Seq, Print, Read
  - Operadores: Gt, Mul, Sub
*)




