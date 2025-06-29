(* =====================================================
   TESTES PARA O AVALIADOR DA LINGUAGEM FUNCIONAL
   ===================================================== *)
   
(* NOTA: Os testes deste arquivo foram elaborados com o auxílio
   de Inteligência Artificial (GitHub Copilot) para garantir
   cobertura abrangente das funcionalidades implementadas. *)

(* Para compilar: 
   ocamlc -c Datatypes.ml
   ocamlc -c Eval.ml
   ocamlc -c Test.ml
   ocamlc -o testes Datatypes.cmo Eval.cmo Test.cmo
   
   Para executar:
   ./testes
   
   Para testes interativos:
   ocaml
   #load "Datatypes.cmo";;
   #load "Eval.cmo";;
   #use "Test.ml";;
*)

(* Importa definições do avaliador *)
open Datatypes
open Eval

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

(* Função para testar casos que podem dar erro *)
let teste_eval_erro expr nome =
  try
    let (valor, novo_estado) = eval expr estado_inicial in
    Printf.printf "%s: %s\n" nome (string_of_valor valor)
  with
    | DivisaoPorZero -> Printf.printf "%s: ERRO - Divisão por zero\n" nome
    | TiposIncompativeis msg -> Printf.printf "%s: ERRO - %s\n" nome msg
    | e -> Printf.printf "%s: ERRO - %s\n" nome (Printexc.to_string e)

(* ===== BATERIA DE TESTES BÁSICOS ===== *)

(* Testes dos casos já implementados *)
let () = 
  print_endline "=== TESTES DO AVALIADOR ===";
  
  (* Testes de literais *)
  teste_eval (Num 42) "Teste 1 (Num 42)";
  teste_eval (Bool true) "Teste 2 (Bool true)";
  teste_eval (Bool false) "Teste 3 (Bool false)";
  teste_eval Unit "Teste 4 (Unit)";
  
  print_endline "";
  print_endline "=== TESTES DE OPERAÇÕES ARITMÉTICAS ===";
  
  (* Testes de soma *)
  teste_eval (Binop(Sum, Num 5, Num 3)) "Teste 5 (5 + 3)";
  teste_eval (Binop(Sum, Num 0, Num 10)) "Teste 6 (0 + 10)";
  teste_eval (Binop(Sum, Num (-5), Num 8)) "Teste 7 (-5 + 8)";
  
  (* Testes de subtração *)
  teste_eval (Binop(Sub, Num 10, Num 3)) "Teste 8 (10 - 3)";
  teste_eval (Binop(Sub, Num 5, Num 5)) "Teste 9 (5 - 5)";
  teste_eval (Binop(Sub, Num 2, Num 7)) "Teste 10 (2 - 7)";
  
  (* Testes de multiplicação *)
  teste_eval (Binop(Mul, Num 4, Num 6)) "Teste 11 (4 * 6)";
  teste_eval (Binop(Mul, Num 0, Num 100)) "Teste 12 (0 * 100)";
  teste_eval (Binop(Mul, Num (-3), Num 4)) "Teste 13 (-3 * 4)";
  
  (* Testes de divisão *)
  teste_eval (Binop(Div, Num 15, Num 3)) "Teste 14 (15 / 3)";
  teste_eval (Binop(Div, Num 7, Num 2)) "Teste 15 (7 / 2) - divisão inteira";
  teste_eval (Binop(Div, Num (-10), Num 2)) "Teste 16 (-10 / 2)";
  
  (* Testes de operações aninhadas *)
  teste_eval (Binop(Sum, Binop(Mul, Num 2, Num 3), Num 4)) "Teste 17 ((2 * 3) + 4)";
  teste_eval (Binop(Div, Binop(Sum, Num 10, Num 5), Num 3)) "Teste 18 ((10 + 5) / 3)";
  
  print_endline "";
  print_endline "=== TESTES DE CASOS DE ERRO ===";
  
  (* Teste de divisão por zero *)
  teste_eval_erro (Binop(Div, Num 10, Num 0)) "Teste 19 (10 / 0) - deve dar erro";
  teste_eval_erro (Binop(Div, Num 0, Num 0)) "Teste 20 (0 / 0) - deve dar erro";
  
  (* Teste de tipos incompatíveis *)
  teste_eval_erro (Binop(Sum, Bool true, Num 5)) "Teste 21 (true + 5) - deve dar erro";
  
  print_endline "=== FIM DOS TESTES ===";

  print_endline "";
  print_endline "=== TESTES DE OPERAÇÕES LÓGICAS ===";
  
  (* Testes de AND *)
  teste_eval (Binop(And, Bool true, Bool true)) "Teste L1 (true AND true)";
  teste_eval (Binop(And, Bool true, Bool false)) "Teste L2 (true AND false)";
  teste_eval (Binop(And, Bool false, Bool true)) "Teste L3 (false AND true)";
  teste_eval (Binop(And, Bool false, Bool false)) "Teste L4 (false AND false)";
  
  (* Testes de OR *)
  teste_eval (Binop(Or, Bool true, Bool true)) "Teste L5 (true OR true)";
  teste_eval (Binop(Or, Bool true, Bool false)) "Teste L6 (true OR false)";
  teste_eval (Binop(Or, Bool false, Bool true)) "Teste L7 (false OR true)";
  teste_eval (Binop(Or, Bool false, Bool false)) "Teste L8 (false OR false)";
  
  (* Testes de tipos incompatíveis *)
  teste_eval_erro (Binop(And, Bool true, Num 1)) "Teste L9 (true AND 1) - deve dar erro";
  teste_eval_erro (Binop(Or, Num 0, Bool false)) "Teste L10 (0 OR false) - deve dar erro";
  
  print_endline "";
  print_endline "=== TESTES DE OPERADORES DE COMPARAÇÃO ===";
  
  (* Testes de comparação: menor que (<) *)
  teste_eval (Binop(Lt, Num 5, Num 10)) "Teste C1 (5 < 10)";
  teste_eval (Binop(Lt, Num 10, Num 5)) "Teste C2 (10 < 5)";
  teste_eval (Binop(Lt, Num 7, Num 7)) "Teste C3 (7 < 7)";
  
  (* Testes de comparação: maior que (>) *)
  teste_eval (Binop(Gt, Num 15, Num 7)) "Teste C4 (15 > 7)";
  teste_eval (Binop(Gt, Num 3, Num 8)) "Teste C5 (3 > 8)";
  teste_eval (Binop(Gt, Num 6, Num 6)) "Teste C6 (6 > 6)";
  
  (* Testes de comparação: igual (=) *)
  teste_eval (Binop(Eq, Num 10, Num 10)) "Teste C7 (10 = 10)";
  teste_eval (Binop(Eq, Num 5, Num 8)) "Teste C8 (5 = 8)";
  teste_eval (Binop(Eq, Bool true, Bool true)) "Teste C9 (true = true)";
  teste_eval (Binop(Eq, Bool false, Bool true)) "Teste C10 (false = true)";
  teste_eval (Binop(Eq, Unit, Unit)) "Teste C11 (unit = unit)";
  
  (* Testes de comparação: diferente (≠) *)
  teste_eval (Binop(Neq, Num 15, Num 10)) "Teste C12 (15 ≠ 10)";
  teste_eval (Binop(Neq, Num 7, Num 7)) "Teste C13 (7 ≠ 7)";
  teste_eval (Binop(Neq, Bool true, Bool false)) "Teste C14 (true ≠ false)";
  teste_eval (Binop(Neq, Bool true, Bool true)) "Teste C15 (true ≠ true)";
  teste_eval (Binop(Neq, Unit, Unit)) "Teste C16 (unit ≠ unit)";
  
  (* Testes de comparação com tipos incompatíveis *)
  teste_eval_erro (Binop(Eq, Num 5, Bool true)) "Teste C17 (5 = true) - deve dar erro";
  teste_eval_erro (Binop(Lt, Bool false, Num 0)) "Teste C18 (false < 0) - deve dar erro";
  teste_eval_erro (Binop(Gt, Unit, Num 1)) "Teste C19 (unit > 1) - deve dar erro";
  teste_eval_erro (Binop(Neq, Bool true, Num 1)) "Teste C20 (true ≠ 1) - deve dar erro";
  
  (* Testes de combinações de operadores *)
  teste_eval (Binop(And, Binop(Lt, Num 5, Num 10), Binop(Gt, Num 7, Num 3))) 
    "Teste CO1 ((5 < 10) AND (7 > 3))";
  teste_eval (Binop(Or, Binop(Eq, Num 5, Num 5), Binop(Eq, Num 6, Num 7))) 
    "Teste CO2 ((5 = 5) OR (6 = 7))";
  teste_eval (Binop(Eq, Binop(Sum, Num 5, Num 5), Num 10)) 
    "Teste CO3 ((5 + 5) = 10)";
  teste_eval (Binop(Or, Binop(Lt, Num 5, Num 3), Binop(Neq, Num 7, Num 7))) 
    "Teste CO4 ((5 < 3) OR (7 ≠ 7))";
  
  print_endline "";
  print_endline "=== TESTES DE CURTO-CIRCUITO ===";
  
  (* Testes de curto-circuito para AND e OR *)
  teste_eval (Binop(And, Bool false, Bool true)) "Teste SC1 (false AND true) - não deve avaliar o segundo operando";
  teste_eval (Binop(And, Bool false, Binop(Div, Num 1, Num 0))) 
    "Teste SC2 (false AND (1/0)) - curto-circuito evita divisão por zero";
  teste_eval (Binop(Or, Bool true, Bool false)) "Teste SC3 (true OR false) - não deve avaliar o segundo operando";
  teste_eval (Binop(Or, Bool true, Binop(Div, Num 1, Num 0))) 
    "Teste SC4 (true OR (1/0)) - curto-circuito evita divisão por zero";
    
  print_endline "";
  print_endline "=== TESTES DE EXPRESSÕES COMPLEXAS ===";
    
  (* Testes de expressões mais complexas *)
  teste_eval (Binop(Sum, 
                  Binop(Mul, Num 3, Num 4), 
                  Binop(Div, Num 10, Num 2)))
    "Teste EX1 ((3 * 4) + (10 / 2)) = 17";
    
  teste_eval (Binop(And,
                  Binop(Gt, Binop(Sum, Num 5, Num 5), Num 9),
                  Binop(Lt, Binop(Sub, Num 20, Num 5), Num 20)))
    "Teste EX2 (((5 + 5) > 9) AND ((20 - 5) < 20)) = true";
    
  teste_eval (Binop(Or,
                  Binop(Neq, Binop(Div, Num 10, Num 3), Num 3),
                  Binop(Lt, Binop(Mul, Num (-2), Num 3), Num 0)))
    "Teste EX3 (((10 / 3) ≠ 3) OR ((-2 * 3) < 0)) = true";
    
  teste_eval (Binop(Eq,
                  Binop(Sum, Binop(Mul, Num 2, Num 3), Num 4),
                  Binop(Sub, Binop(Mul, Num 5, Num 2), Num 0)))
    "Teste EX4 (((2 * 3) + 4) = ((5 * 2) - 0)) = true";
  
  print_endline "";
  print_endline "=== FIM DOS TESTES ==="

(* Definições para testes interativos *)
let teste1 = eval (Num 42) estado_inicial
let teste2 = eval (Bool true) estado_inicial
let teste3 = eval Unit estado_inicial
