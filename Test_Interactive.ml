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
  print_endline ""

(* 3. Testes de casos de erro *)
let testes_erros () =
  print_endline "=== TESTES DE CASOS DE ERRO ===";
  
  (* Teste de divisão por zero *)
  teste_eval_erro (Binop(Div, Num 10, Num 0)) "Teste 19 (10 / 0) - deve dar erro";
  teste_eval_erro (Binop(Div, Num 0, Num 0)) "Teste 20 (0 / 0) - deve dar erro";
  
  (* Teste de tipos incompatíveis *)
  teste_eval_erro (Binop(Sum, Bool true, Num 5)) "Teste 21 (true + 5) - deve dar erro";
  print_endline ""

(* 4. Testes lógicos *)
let testes_logicos () =
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
  print_endline ""

(* 5. Testes de comparação *)
let testes_comparacao () =
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
  
  (* Testes de comparação: diferente (!=) *)
  teste_eval (Binop(Neq, Num 15, Num 10)) "Teste C12 (15 != 10)";
  teste_eval (Binop(Neq, Num 7, Num 7)) "Teste C13 (7 != 7)";
  teste_eval (Binop(Neq, Bool true, Bool false)) "Teste C14 (true != false)";
  teste_eval (Binop(Neq, Bool true, Bool true)) "Teste C15 (true != true)";
  teste_eval (Binop(Neq, Unit, Unit)) "Teste C16 (unit != unit)";
  
  (* Testes de comparação com tipos incompatíveis *)
  teste_eval_erro (Binop(Eq, Num 5, Bool true)) "Teste C17 (5 = true) - deve dar erro";
  teste_eval_erro (Binop(Lt, Bool false, Num 0)) "Teste C18 (false < 0) - deve dar erro";
  teste_eval_erro (Binop(Gt, Unit, Num 1)) "Teste C19 (unit > 1) - deve dar erro";
  teste_eval_erro (Binop(Neq, Bool true, Num 1)) "Teste C20 (true != 1) - deve dar erro";
  print_endline ""

(* 6. Testes de curto-circuito *)
let testes_curto_circuito () =
  print_endline "=== TESTES DE CURTO-CIRCUITO ===";
  
  (* Testes de curto-circuito para AND e OR *)
  teste_eval (Binop(And, Bool false, Bool true)) "Teste SC1 (false AND true) - não deve avaliar o segundo operando";
  teste_eval (Binop(And, Bool false, Binop(Div, Num 1, Num 0))) 
    "Teste SC2 (false AND (1/0)) - curto-circuito evita divisão por zero";
  teste_eval (Binop(Or, Bool true, Bool false)) "Teste SC3 (true OR false) - não deve avaliar o segundo operando";
  teste_eval (Binop(Or, Bool true, Binop(Div, Num 1, Num 0))) 
    "Teste SC4 (true OR (1/0)) - curto-circuito evita divisão por zero";
  print_endline ""

(* 7. Testes de expressões complexas *)
let testes_expressoes_complexas () =
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
    "Teste EX3 (((10 / 3) != 3) OR ((-2 * 3) < 0)) = true";
    
  teste_eval (Binop(Eq,
                  Binop(Sum, Binop(Mul, Num 2, Num 3), Num 4),
                  Binop(Sub, Binop(Mul, Num 5, Num 2), Num 0)))
    "Teste EX4 (((2 * 3) + 4) = ((5 * 2) - 0)) = true";
  print_endline ""

(* 8. Testes de If *)
let testes_if () =
  print_endline "=== TESTES DE EXPRESSÕES CONDICIONAIS (IF) ===";
  
  (* Testes básicos de if-then-else *)
  teste_eval (If(Bool true, Num 1, Num 2)) 
    "Teste IF1 (if true then 1 else 2) = 1";
  teste_eval (If(Bool false, Num 1, Num 2)) 
    "Teste IF2 (if false then 1 else 2) = 2";
    
  (* Testes com condições complexas *)
  teste_eval (If(Binop(Lt, Num 5, Num 10), 
                Bool true, 
                Bool false))
    "Teste IF3 (if (5 < 10) then true else false) = true";
  teste_eval (If(Binop(Eq, Num 7, Num 7), 
                Binop(Sum, Num 5, Num 5), 
                Num 0))
    "Teste IF4 (if (7 = 7) then (5 + 5) else 0) = 10";
    
  (* Testes de aninhamento de ifs *)
  teste_eval (If(Binop(Gt, Num 10, Num 5),
                If(Binop(Lt, Num 3, Num 4), 
                   Num 1, 
                   Num 2),
                Num 3))
    "Teste IF5 (if (10 > 5) then (if (3 < 4) then 1 else 2) else 3) = 1";
    
  (* Testes de erro com condição não booleana *)
  teste_eval_erro (If(Num 1, Num 2, Num 3))
    "Teste IF6 (if 1 then 2 else 3) - deve dar erro";
    
  print_endline "=== TESTES DE VERIFICAÇÃO DE TIPOS NO IF ===";
    
  (* Testes para garantir que ambos os ramos do if tenham o mesmo tipo *)
  teste_eval (If(Bool true, Num 10, Num 20)) 
    "Teste IF-TIPO1 (if true then 10 else 20) - mesmos tipos";
  teste_eval (If(Bool false, Bool true, Bool false)) 
    "Teste IF-TIPO2 (if false then true else false) - mesmos tipos";
  teste_eval (If(Binop(Lt, Num 5, Num 10), Unit, Unit)) 
    "Teste IF-TIPO3 (if (5 < 10) then unit else unit) - mesmos tipos";
    
  (* Testes para verificação de tipos diferentes nos ramos *)
  teste_eval_erro (If(Bool true, Num 5, Bool true)) 
    "Teste IF-TIPO4 (if true then 5 else true) - tipos diferentes, deve dar erro";
  teste_eval_erro (If(Bool false, Unit, Num 10)) 
    "Teste IF-TIPO5 (if false then unit else 10) - tipos diferentes, deve dar erro";
  teste_eval_erro (If(Binop(Gt, Num 7, Num 3), Bool false, Num 0)) 
    "Teste IF-TIPO6 (if (7 > 3) then false else 0) - tipos diferentes, deve dar erro";
    
  (* Teste com expressões mais complexas em ambos os ramos *)
  teste_eval (If(Binop(Eq, Num 5, Num 5),
                Binop(Sum, Num 10, Num 20),
                Binop(Mul, Num 5, Num 6)))
    "Teste IF-TIPO7 (if (5 = 5) then (10 + 20) else (5 * 6)) - ambos retornam Int";
  teste_eval_erro (If(Binop(Neq, Num 7, Num 7),
                     Binop(Sum, Num 5, Num 5),
                     Binop(Lt, Num 3, Num 4)))
    "Teste IF-TIPO8 (if (7 != 7) then (5 + 5) else (3 < 4)) - tipos diferentes (Int e Bool), deve dar erro";
  print_endline ""

(* 9. Testes de variáveis (Let e Id) *)
let testes_variaveis () =
  print_endline "=== TESTES DE VARIÁVEIS (LET e ID) ===";
  
  (* Testes básicos de Let *)
  teste_eval (Let("x", TyInt, Num 42, Id "x")) 
    "Teste VAR1 (let x: int = 42 in x) = 42";
  teste_eval (Let("y", TyBool, Bool true, Id "y")) 
    "Teste VAR2 (let y: bool = true in y) = true";
  teste_eval (Let("z", TyUnit, Unit, Id "z")) 
    "Teste VAR3 (let z: unit = () in z) = unit";
    
  (* Testes de Let com expressões complexas *)
  teste_eval (Let("a", TyInt, Binop(Sum, Num 10, Num 5), Id "a"))
    "Teste VAR4 (let a: int = (10 + 5) in a) = 15";
  teste_eval (Let("b", TyBool, Binop(Lt, Num 5, Num 10), Id "b"))
    "Teste VAR5 (let b: bool = (5 < 10) in b) = true";
    
  (* Testes de Let com corpo complexo *)
  teste_eval (Let("x", TyInt, Num 5, Binop(Sum, Id "x", Num 10)))
    "Teste VAR6 (let x: int = 5 in (x + 10)) = 15";
  teste_eval (Let("y", TyBool, Bool false, If(Id "y", Num 1, Num 2)))
    "Teste VAR7 (let y: bool = false in (if y then 1 else 2)) = 2";
    
  (* Testes de aninhamento de Let *)
  teste_eval (Let("x", TyInt, Num 10, 
                 Let("y", TyInt, Num 20, 
                    Binop(Sum, Id "x", Id "y"))))
    "Teste VAR8 (let x: int = 10 in (let y: int = 20 in (x + y))) = 30";
    
  (* Testes de escopo: variável interna oculta externa *)
  teste_eval (Let("x", TyInt, Num 5, 
                 Let("x", TyInt, Num 10, 
                    Id "x")))
    "Teste VAR9 (let x: int = 5 in (let x: int = 10 in x)) = 10 (escopo interno)";
    
  (* Testes com diferentes tipos *)
  teste_eval (Let("num", TyInt, Num 42,
                 Let("flag", TyBool, Bool true,
                    Let("nothing", TyUnit, Unit,
                       If(Id "flag", Id "num", Num 0)))))
    "Teste VAR10 (múltiplas variáveis de tipos diferentes) = 42";
    
  (* Testes de erro: variável não encontrada *)
  teste_eval_erro (Id "x")
    "Teste VAR11 (x) - variável não definida, deve dar erro";
  teste_eval_erro (Let("y", TyInt, Num 5, Id "x"))
    "Teste VAR12 (let y: int = 5 in x) - x não definida, deve dar erro";
    
  (* Testes de expressões com variáveis *)
  teste_eval (Let("a", TyInt, Num 3,
                 Let("b", TyInt, Num 4,
                    Binop(Mul, Id "a", Id "b"))))
    "Teste VAR13 (let a: int = 3 in (let b: int = 4 in (a * b))) = 12";
    
  teste_eval (Let("x", TyInt, Num 7,
                 Let("y", TyInt, Num 3,
                    Binop(Gt, Id "x", Id "y"))))
    "Teste VAR14 (let x: int = 7 in (let y: int = 3 in (x > y))) = true";
    
  (* Testes de Let com condicionais *)
  teste_eval (Let("condition", TyBool, Bool true,
                 Let("val1", TyInt, Num 100,
                    Let("val2", TyInt, Num 200,
                       If(Id "condition", Id "val1", Id "val2")))))
    "Teste VAR15 (if com variáveis) = 100";
    
  (* Testes de reutilização de variáveis *)
  teste_eval (Let("x", TyInt, Num 5,
                 Binop(Sum, Id "x", Id "x")))
    "Teste VAR16 (let x: int = 5 in (x + x)) = 10";
    
  teste_eval (Let("flag", TyBool, Bool false,
                 Binop(Or, Id "flag", Bool true)))
    "Teste VAR17 (let flag: bool = false in (flag OR true)) = true";

  (* Testes de expressões aninhadas com variáveis *)
  teste_eval (Let("a", TyInt, Num 2,
                 Let("b", TyInt, Num 3,
                    Let("c", TyInt, Num 4,
                       Binop(Sum, 
                             Binop(Mul, Id "a", Id "b"),
                             Id "c")))))
    "Teste VAR18 (let a=2 in let b=3 in let c=4 in ((a*b)+c)) = 10";
  print_endline ""

(* 10. Testes de Sequenciamento (Seq) *)
let testes_sequenciamento () =
  print_endline "=== TESTES DE SEQUENCIAMENTO (SEQ) ===";
  
  (* Testes básicos de sequenciamento *)
  teste_eval (Seq(Num 5, Num 10)) 
    "Teste SEQ1 (5; 10) = 10 - descarta primeiro valor";
  teste_eval (Seq(Bool true, Bool false)) 
    "Teste SEQ2 (true; false) = false";
  teste_eval (Seq(Unit, Num 42)) 
    "Teste SEQ3 ((); 42) = 42";
    
  (* Testes com expressões complexas *)
  teste_eval (Seq(Binop(Sum, Num 2, Num 3), Binop(Mul, Num 4, Num 5)))
    "Teste SEQ4 ((2+3); (4*5)) = 20 - descarta resultado da soma";
  
  (* Testes aninhados *)
  teste_eval (Seq(Seq(Num 1, Num 2), Num 3))
    "Teste SEQ5 ((1; 2); 3) = 3 - sequenciamento aninhado";
    
  (* Testes com variáveis *)
  teste_eval (Let("x", TyInt, Num 10,
                 Seq(Id "x", Binop(Sum, Id "x", Num 5))))
    "Teste SEQ6 (let x=10 in (x; x+5)) = 15";
    
  (* Testes com condicionais *)
  teste_eval (Seq(If(Bool true, Num 1, Num 2), Num 100))
    "Teste SEQ7 ((if true then 1 else 2); 100) = 100";
    
  print_endline ""

(* 11. Testes de Referencias (New) *)
let testes_referencias () =
  print_endline "=== TESTES DE REFERENCIAS (NEW) ===";
  
  (* Testes basicos de criacao de referencias *)
  teste_eval (New(Num 42)) 
    "Teste REF1 (new 42) - cria referencia para inteiro";
  teste_eval (New(Bool true)) 
    "Teste REF2 (new true) - cria referencia para booleano";
  teste_eval (New(Unit)) 
    "Teste REF3 (new ()) - cria referencia para unit";
    
  (* Testes com expressoes como valor da referencia *)
  teste_eval (New(Binop(Sum, Num 10, Num 5))) 
    "Teste REF4 (new (10 + 5)) - cria referencia para resultado de expressao";
  teste_eval (New(Binop(Lt, Num 5, Num 10))) 
    "Teste REF5 (new (5 < 10)) - cria referencia para resultado booleano";
    
  (* Testes com variaveis *)
  teste_eval (Let("x", TyInt, Num 25, New(Id "x"))) 
    "Teste REF6 (let x: int = 25 in new x) - cria referencia para variavel";
    
  (* Testes de criacao de multiplas referencias *)
  teste_eval (Seq(New(Num 10), New(Num 20))) 
    "Teste REF7 (new 10; new 20) - enderecos devem ser diferentes";
    
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
  print_endline " 12. Executar TODOS os testes";
  print_endline "  0. Sair";
  print_endline "";
  print_string "Digite sua opção (0-12): ";
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
     | 12 -> executar_todos_testes (); loop_principal ()
     | _ -> 
         print_endline "Opção inválida! Tente novamente.";
         print_endline "";
         loop_principal ())
  with
  | Failure _ ->
      print_endline "Entrada inválida! Digite um número entre 0 e 12.";
      print_endline "";
      loop_principal ()

(* ===== PROGRAMA PRINCIPAL ===== *)

let () = 
  print_endline "";
  print_endline "Bem-vindo ao Sistema de Testes do Avaliador!";
  loop_principal ()
