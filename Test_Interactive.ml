(* =====================================================
   TESTES INTERATIVOS PARA O AVALIADOR DA LINGUAGEM FUNCIONAL
   ===================================================== *)

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

(* ===== FUNÇÕES DE TESTE ORGANIZADAS ===== *)

(* 1. Testes de literais *)
let testes_literais () =
  print_endline "=== TESTES DE LITERAIS ===";
  teste_eval (Num 42) "Teste 1 (Num 42)";
  teste_eval (Bool true) "Teste 2 (Bool true)";
  teste_eval (Bool false) "Teste 3 (Bool false)";
  teste_eval Unit "Teste 4 (Unit)";
  print_endline ""

(* 2. Testes aritméticos *)
let testes_aritmeticos () =
  print_endline "=== TESTES DE OPERAÇÕES ARITMÉTICAS ===";
  teste_eval (Binop(Sum, Num 5, Num 3)) "Teste 5 (5 + 3)";
  teste_eval (Binop(Sub, Num 10, Num 3)) "Teste 6 (10 - 3)";
  teste_eval (Binop(Mul, Num 4, Num 6)) "Teste 7 (4 * 6)";
  teste_eval (Binop(Div, Num 15, Num 3)) "Teste 8 (15 / 3)";
  print_endline ""

(* 3. Testes de casos de erro *)
let testes_erros () =
  print_endline "=== TESTES DE CASOS DE ERRO ===";
  teste_eval_erro (Binop(Div, Num 10, Num 0)) "Teste 9 (10 / 0) - deve dar erro";
  teste_eval_erro (Binop(Sum, Bool true, Num 5)) "Teste 10 (true + 5) - deve dar erro";
  print_endline ""

(* 4. Testes lógicos *)
let testes_logicos () =
  print_endline "=== TESTES DE OPERAÇÕES LÓGICAS ===";
  teste_eval (Binop(And, Bool true, Bool true)) "Teste 11 (true AND true)";
  teste_eval (Binop(And, Bool true, Bool false)) "Teste 12 (true AND false)";
  teste_eval (Binop(Or, Bool true, Bool false)) "Teste 13 (true OR false)";
  teste_eval (Binop(Or, Bool false, Bool false)) "Teste 14 (false OR false)";
  print_endline ""

(* 5. Testes de comparação *)
let testes_comparacao () =
  print_endline "=== TESTES DE OPERADORES DE COMPARAÇÃO ===";
  teste_eval (Binop(Lt, Num 5, Num 10)) "Teste 15 (5 < 10)";
  teste_eval (Binop(Gt, Num 15, Num 7)) "Teste 16 (15 > 7)";
  teste_eval (Binop(Eq, Num 10, Num 10)) "Teste 17 (10 = 10)";
  teste_eval (Binop(Neq, Num 15, Num 10)) "Teste 18 (15 != 10)";
  print_endline ""

(* 6. Testes de curto-circuito *)
let testes_curto_circuito () =
  print_endline "=== TESTES DE CURTO-CIRCUITO ===";
  teste_eval (Binop(And, Bool false, Bool true)) "Teste 19 (false AND true) - curto-circuito";
  teste_eval (Binop(Or, Bool true, Bool false)) "Teste 20 (true OR false) - curto-circuito";
  print_endline ""

(* 7. Testes de expressões complexas *)
let testes_expressoes_complexas () =
  print_endline "=== TESTES DE EXPRESSÕES COMPLEXAS ===";
  teste_eval (Binop(Sum, Binop(Mul, Num 3, Num 4), Binop(Div, Num 10, Num 2))) "Teste 21 ((3*4)+(10/2))";
  teste_eval (Binop(And, Binop(Gt, Num 10, Num 5), Binop(Lt, Num 15, Num 20))) "Teste 22 ((10>5) AND (15<20))";
  print_endline ""

(* 8. Testes de expressões condicionais (IF) *)
let testes_if () =
  print_endline "=== TESTES DE EXPRESSÕES CONDICIONAIS (IF) ===";
  teste_eval (If(Bool true, Num 1, Num 2)) "Teste 23 (if true then 1 else 2)";
  teste_eval (If(Bool false, Num 1, Num 2)) "Teste 24 (if false then 1 else 2)";
  teste_eval (If(Binop(Lt, Num 5, Num 10), Bool true, Bool false)) "Teste 25 (if (5<10) then true else false)";
  teste_eval_erro (If(Num 1, Num 2, Num 3)) "Teste 26 (if 1 then 2 else 3) - deve dar erro";
  print_endline ""

(* 9. Testes de variáveis (LET/ID) *)
let testes_variaveis () =
  print_endline "=== TESTES DE VARIÁVEIS (LET e ID) ===";
  teste_eval (Let("x", TyInt, Num 42, Id "x")) "Teste 27 (let x: int = 42 in x)";
  teste_eval (Let("y", TyBool, Bool true, Id "y")) "Teste 28 (let y: bool = true in y)";
  teste_eval (Let("x", TyInt, Num 5, Binop(Sum, Id "x", Num 10))) "Teste 29 (let x: int = 5 in (x + 10))";
  teste_eval (Let("x", TyInt, Num 10, Let("y", TyInt, Num 20, Binop(Sum, Id "x", Id "y")))) "Teste 30 (let x=10 in let y=20 in (x+y))";
  teste_eval_erro (Id "z") "Teste 31 (z) - variável não definida, deve dar erro";
  print_endline ""

(* 10. Testes de sequenciamento (SEQ) *)
let testes_sequenciamento () =
  print_endline "=== TESTES DE SEQUENCIAMENTO (SEQ) ===";
  teste_eval (Seq(Num 1, Num 2)) "Teste 32 (1; 2) - retorna 2";
  teste_eval (Seq(Bool true, Bool false)) "Teste 33 (true; false) - retorna false";
  teste_eval (Seq(Unit, Num 42)) "Teste 34 ((); 42) - retorna 42";
  teste_eval (Seq(Seq(Num 1, Num 2), Num 3)) "Teste 35 ((1; 2); 3) - retorna 3";
  print_endline ""

(* 11. Testes de referencias (NEW) *)
let testes_referencias () =
  print_endline "=== TESTES DE REFERENCIAS (NEW) ===";
  teste_eval (New(Num 42)) "Teste 36 (new 42) - cria referencia para inteiro";
  teste_eval (New(Bool true)) "Teste 37 (new true) - cria referencia para booleano";
  teste_eval (New(Unit)) "Teste 38 (new ()) - cria referencia para unit";
  teste_eval (Let("x", TyInt, Num 25, New(Id "x"))) "Teste 39 (let x=25 in new x)";
  print_endline ""

(* 12. Testes de desreferenciamento (DEREF) *)
let testes_deref () =
  print_endline "=== TESTES DE DESREFERENCIAMENTO (DEREF) ===";
  teste_eval (Let("r", TyRef TyInt, New(Num 42), Deref(Id "r"))) "Teste 40 (let r = new 42 in !r)";
  teste_eval (Let("r", TyRef TyBool, New(Bool true), Deref(Id "r"))) "Teste 41 (let r = new true in !r)";
  teste_eval (Let("r", TyRef TyUnit, New(Unit), Deref(Id "r"))) "Teste 42 (let r = new () in !r)";
  teste_eval_erro (Deref(Num 42)) "Teste 43 (!42) - deve dar erro (não é referência)";
  print_endline ""

(* 13. Testes de atribuição (ASG) *)
let testes_atribuicao () =
  print_endline "=== TESTES DE ATRIBUIÇÃO (ASG) ===";
  teste_eval (Let("r", TyRef TyInt, New(Num 42), Seq(Asg(Id "r", Num 100), Deref(Id "r")))) "Teste 44 (r := 100; !r)";
  teste_eval (Let("r", TyRef TyBool, New(Bool false), Seq(Asg(Id "r", Bool true), Deref(Id "r")))) "Teste 45 (r := true; !r)";
  teste_eval_erro (Asg(Num 42, Num 100)) "Teste 46 (42 := 100) - deve dar erro (não é referência)";
  print_endline ""

(* 14. Testes de while (WH) *)
let testes_while () =
  print_endline "=== TESTES DE WHILE (WH) ===";
  teste_eval (Wh(Bool false, Print(Num 999))) "Teste 47 (while false do print 999) - não deve executar";
  teste_eval (Let("counter", TyRef TyInt, New(Num 0),
             Seq(Wh(Binop(Lt, Deref(Id "counter"), Num 3),
                   Asg(Id "counter", Binop(Sum, Deref(Id "counter"), Num 1))),
                Deref(Id "counter"))))
    "Teste 48 (contador de 0 a 3) - deve retornar 3";
  teste_eval_erro (Wh(Num 42, Unit)) "Teste 49 (while 42 do ()) - deve dar erro (condição não booleana)";
  print_endline ""

(* 15. Testes de print *)
let testes_print () =
  print_endline "=== TESTES DE PRINT ===";
  teste_eval (Print(Num 42)) "Teste 50 (print 42) - imprime inteiro";
  teste_eval (Print(Bool true)) "Teste 51 (print true) - imprime booleano";
  teste_eval (Print(Unit)) "Teste 52 (print ()) - imprime unit";
  teste_eval (Let("r", TyRef TyInt, New(Num 100), Print(Deref(Id "r")))) "Teste 53 (print !r)";
  print_endline ""

(* ===== MENU INTERATIVO ===== *)

let mostrar_menu () =
  print_endline "";
  print_endline "==================================================";
  print_endline "    SISTEMA DE TESTES INTERATIVO - AVALIADOR";
  print_endline "==================================================";
  print_endline "";
  print_endline "Escolha qual tipo de teste executar:";
  print_endline "";
  print_endline "  1. Literais (Num, Bool, Unit)";
  print_endline "  2. Operações Aritméticas (+, -, *, /)";
  print_endline "  3. Casos de Erro (divisão por zero, tipos)";
  print_endline "  4. Operações Lógicas (AND, OR)";
  print_endline "  5. Operadores de Comparação (<, >, =, !=)";
  print_endline "  6. Curto-circuito (AND/OR)";
  print_endline "  7. Expressões Complexas";
  print_endline "  8. Expressões Condicionais (IF)";
  print_endline "  9. Variáveis (LET/ID)";
  print_endline " 10. Sequenciamento (SEQ)";
  print_endline " 11. Referencias (NEW)";
  print_endline " 12. Desreferenciamento (DEREF)";
  print_endline " 13. Atribuição (ASG)";
  print_endline " 14. While (WH)";
  print_endline " 15. Print";
  print_endline " 16. Executar TODOS os testes";
  print_endline "  0. Sair";
  print_endline "";
  print_string "Digite sua opção (0-16): ";
  flush_all ()

let executar_todos_testes () =
  print_endline "=== EXECUTANDO TODOS OS TESTES ===";
  print_endline "";
  testes_literais ();
  testes_aritmeticos ();
  testes_erros ();
  testes_logicos ();
  testes_comparacao ();
  testes_curto_circuito ();
  testes_expressoes_complexas ();
  testes_if ();
  testes_variaveis ();
  testes_sequenciamento ();
  testes_referencias ();
  testes_deref ();
  testes_atribuicao ();
  testes_while ();
  testes_print ();
  print_endline "=== TODOS OS TESTES CONCLUÍDOS ===";
  print_endline ""

let rec loop_principal () =
  mostrar_menu ();
  try
    let opcao = read_int () in
    print_endline "";
    (match opcao with
     | 0 -> 
         print_endline "Saindo do sistema de testes. Até logo!";
         print_endline ""
     | 1 -> testes_literais (); loop_principal ()
     | 2 -> testes_aritmeticos (); loop_principal ()
     | 3 -> testes_erros (); loop_principal ()
     | 4 -> testes_logicos (); loop_principal ()
     | 5 -> testes_comparacao (); loop_principal ()
     | 6 -> testes_curto_circuito (); loop_principal ()
     | 7 -> testes_expressoes_complexas (); loop_principal ()
     | 8 -> testes_if (); loop_principal ()
     | 9 -> testes_variaveis (); loop_principal ()
     | 10 -> testes_sequenciamento (); loop_principal ()
     | 11 -> testes_referencias (); loop_principal ()
     | 12 -> testes_deref (); loop_principal ()
     | 13 -> testes_atribuicao (); loop_principal ()
     | 14 -> testes_while (); loop_principal ()
     | 15 -> testes_print (); loop_principal ()
     | 16 -> executar_todos_testes (); loop_principal ()
     | _ -> 
         print_endline "Opção inválida! Tente novamente.";
         print_endline "";
         loop_principal ())
  with
  | Failure _ ->
      print_endline "Entrada inválida! Digite um número entre 0 e 16.";
      print_endline "";
      loop_principal ()

(* ===== PROGRAMA PRINCIPAL ===== *)

let () = 
  print_endline "";
  print_endline "Bem-vindo ao Sistema de Testes do Avaliador!";
  loop_principal ()
