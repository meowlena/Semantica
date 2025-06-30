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
                   Asg(Id "counter", Binop(Sum, Deref(Id "counter"), Num 1))),
                Deref(Id "counter"))))
    "Teste WH2 (contador de 0 a 3) - deve retornar 3";es Datatypes.cmo Eval.cmo Test.cmo
   
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

(* ===== FUNÇÕES DE TESTE ORGANIZADAS ===== *)

(* Função para testes de literais *)
let testes_literais () =
  print_endline "=== TESTES DE LITERAIS ===";
  teste_eval (Num 42) "Teste 1 (Num 42)";
  teste_eval (Bool true) "Teste 2 (Bool true)";
  teste_eval (Bool false) "Teste 3 (Bool false)";
  teste_eval Unit "Teste 4 (Unit)";
  print_endline ""

(* Função para testes aritméticos *)
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

(* Função para testes de casos de erro *)
let testes_erros () =
  print_endline "=== TESTES DE CASOS DE ERRO ===";
  
  (* Teste de divisão por zero *)
  teste_eval_erro (Binop(Div, Num 10, Num 0)) "Teste 19 (10 / 0) - deve dar erro";
  teste_eval_erro (Binop(Div, Num 0, Num 0)) "Teste 20 (0 / 0) - deve dar erro";
  
  (* Teste de tipos incompatíveis *)
  teste_eval_erro (Binop(Sum, Bool true, Num 5)) "Teste 21 (true + 5) - deve dar erro";
  print_endline ""

(* Função para testes lógicos *)
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
  
  (* Testes de combinações de operadores *)
  teste_eval (Binop(And, Binop(Lt, Num 5, Num 10), Binop(Gt, Num 7, Num 3))) 
    "Teste CO1 ((5 < 10) AND (7 > 3))";
  teste_eval (Binop(Or, Binop(Eq, Num 5, Num 5), Binop(Eq, Num 6, Num 7))) 
    "Teste CO2 ((5 = 5) OR (6 = 7))";
  teste_eval (Binop(Eq, Binop(Sum, Num 5, Num 5), Num 10)) 
    "Teste CO3 ((5 + 5) = 10)";
  teste_eval (Binop(Or, Binop(Lt, Num 5, Num 3), Binop(Neq, Num 7, Num 7))) 
    "Teste CO4 ((5 < 3) OR (7 != 7))";
  
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
    "Teste EX3 (((10 / 3) != 3) OR ((-2 * 3) < 0)) = true";
    
  teste_eval (Binop(Eq,
                  Binop(Sum, Binop(Mul, Num 2, Num 3), Num 4),
                  Binop(Sub, Binop(Mul, Num 5, Num 2), Num 0)))
    "Teste EX4 (((2 * 3) + 4) = ((5 * 2) - 0)) = true";
  
  print_endline "";
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
    
  print_endline "";
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
  
  print_endline "";
  print_endline "=== FIM DOS TESTES ===";

  print_endline "";
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

  print_endline "";
  print_endline "=== FIM DOS TESTES ==="

(* Função para testes de referencias (NEW) *)
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
  teste_eval (New(If(Bool true, Num 100, Num 200))) 
    "Teste REF6 (new (if true then 100 else 200)) - cria referencia para resultado de if";
    
  (* Testes com variaveis *)
  teste_eval (Let("x", TyInt, Num 25, New(Id "x"))) 
    "Teste REF7 (let x: int = 25 in new x) - cria referencia para variavel";
  teste_eval (Let("y", TyBool, Bool false, New(Id "y"))) 
    "Teste REF8 (let y: bool = false in new y) - cria referencia para variavel booleana";
    
  (* Testes de criacao de multiplas referencias *)
  teste_eval (Seq(New(Num 10), New(Num 20))) 
    "Teste REF9 (new 10; new 20) - cria duas referencias em sequencia";
  teste_eval (Let("r1", TyRef TyInt, New(Num 100),
                 Let("r2", TyRef TyBool, New(Bool true),
                    New(Num 300))))
    "Teste REF10 (multiplas referencias) - enderecos devem ser diferentes";
    
  (* Testes com expressoes complexas *)
  teste_eval (New(Let("temp", TyInt, Num 7, Binop(Mul, Id "temp", Num 6))))
    "Teste REF11 (new (let temp: int = 7 in (temp * 6))) - referencia para resultado complexo";
    
  (* Teste de aninhamento de New *)
  teste_eval (New(New(Num 42)))
    "Teste REF12 (new (new 42)) - referencia para referencia";
    
  print_endline ""

(* Função para testes de desreferenciamento (DEREF) *)
let testes_deref () =
  print_endline "=== TESTES DE DESREFERENCIAMENTO (DEREF) ===";
  
  (* Testes basicos de desreferenciamento *)
  teste_eval (Let("r", TyRef TyInt, New(Num 42), Deref(Id "r")))
    "Teste DEREF1 (let r = new 42 in !r) - desreferencia inteiro";
  teste_eval (Let("r", TyRef TyBool, New(Bool true), Deref(Id "r")))
    "Teste DEREF2 (let r = new true in !r) - desreferencia booleano";
  teste_eval (Let("r", TyRef TyUnit, New(Unit), Deref(Id "r")))
    "Teste DEREF3 (let r = new () in !r) - desreferencia unit";
    
  (* Testes com expressoes *)
  teste_eval (Let("r", TyRef TyInt, New(Binop(Sum, Num 10, Num 5)), Deref(Id "r")))
    "Teste DEREF4 (let r = new (10 + 5) in !r) - desreferencia resultado de expressao";
  teste_eval (Let("r", TyRef TyBool, New(Binop(Lt, Num 5, Num 10)), Deref(Id "r")))
    "Teste DEREF5 (let r = new (5 < 10) in !r) - desreferencia resultado booleano";
    
  (* Teste de desreferenciamento de referencia para referencia *)
  teste_eval (Let("r1", TyRef TyInt, New(Num 100),
             Let("r2", TyRef (TyRef TyInt), New(Id "r1"),
                Deref(Deref(Id "r2")))))
    "Teste DEREF6 (desreferenciamento duplo) - !!r2 onde r2 aponta para r1";
    
  (* Teste de erro - tentar desreferenciar nao-referencia *)
  teste_eval_erro (Deref(Num 42))
    "Teste DEREF7 (!42) - deve dar erro (nao e referencia)";
  teste_eval_erro (Deref(Bool true))
    "Teste DEREF8 (!true) - deve dar erro (nao e referencia)";
    
  print_endline ""

(* Função para testes de atribuição (ASG) *)
let testes_atribuicao () =
  print_endline "=== TESTES DE ATRIBUICAO (ASG) ===";
  
  (* Testes basicos de atribuicao *)
  teste_eval (Let("r", TyRef TyInt, New(Num 42), 
             Seq(Asg(Id "r", Num 100), Deref(Id "r"))))
    "Teste ASG1 (r := 100; !r) - atribuicao e leitura";
  teste_eval (Let("r", TyRef TyBool, New(Bool false), 
             Seq(Asg(Id "r", Bool true), Deref(Id "r"))))
    "Teste ASG2 (r := true; !r) - atribuicao booleana";
    
  (* Testes com expressoes *)
  teste_eval (Let("r", TyRef TyInt, New(Num 0), 
             Seq(Asg(Id "r", Binop(Sum, Num 10, Num 5)), Deref(Id "r"))))
    "Teste ASG3 (r := 10+5; !r) - atribuicao de expressao";
  teste_eval (Let("r", TyRef TyBool, New(Bool true), 
             Seq(Asg(Id "r", Binop(Gt, Num 10, Num 5)), Deref(Id "r"))))
    "Teste ASG4 (r := 10>5; !r) - atribuicao de comparacao";
    
  (* Teste de multiplas atribuicoes *)
  teste_eval (Let("r", TyRef TyInt, New(Num 1), 
             Seq(Asg(Id "r", Num 2),
             Seq(Asg(Id "r", Num 3), 
             Deref(Id "r")))))
    "Teste ASG5 (multiplas atribuicoes) - deve retornar ultimo valor";
    
  (* Teste de erro - tentar atribuir a nao-referencia *)
  teste_eval_erro (Asg(Num 42, Num 100))
    "Teste ASG6 (42 := 100) - deve dar erro (nao e referencia)";
    
  print_endline ""

(* Função para testes de while (WH) *)
let testes_while () =
  print_endline "=== TESTES DE WHILE (WH) ===";
  
  (* Teste basico de while - loop que nao executa *)
  teste_eval (Wh(Bool false, Print(Num 999)))
    "Teste WH1 (while false do print 999) - nao deve executar";
    
  (* Teste de contador simples *)
  teste_eval (Let("counter", TyRef TyInt, New(Num 0),
             Seq(Wh(Binop(Lt, Deref(Id "counter"), Num 3),
                   Asg(Id "counter", Binop(Sum, Deref(Id "counter"), Num 1))),
                Deref(Id "counter"))))
    "Teste WH2 (contador de 0 a 3) - deve retornar 3";
    
  (* Teste de loop com decremento *)
  teste_eval (Let("counter", TyRef TyInt, New(Num 5),
             Seq(Wh(Binop(Gt, Deref(Id "counter"), Num 0),
                   Asg(Id "counter", Binop(Sub, Deref(Id "counter"), Num 1))),
                Deref(Id "counter"))))
    "Teste WH3 (contador de 5 a 0) - deve retornar 0";
    
  (* Teste de erro - condicao nao booleana *)
  teste_eval_erro (Wh(Num 42, Unit))
    "Teste WH4 (while 42 do ()) - deve dar erro (condicao nao booleana)";
    
  print_endline ""

(* Função para testes do for loop *)
let testes_for () =
  print_endline "=== TESTES DE FOR LOOP ===";
  
  (* Teste basico: soma de 1 a 3 *)
  teste_eval (Let("sum", TyRef TyInt, New(Num 0),
                Seq(For("i", Num 1, Num 3, 
                      Asg(Id "sum", Binop(Sum, Deref(Id "sum"), Deref(Id "i")))),
                   Deref(Id "sum"))))
    "Teste FOR1 (soma de 1 a 3) - deve retornar 6";
    
  (* Teste com for de 1 a 1 *)
  teste_eval (Let("sum", TyRef TyInt, New(Num 0),
                Seq(For("i", Num 1, Num 1, 
                      Asg(Id "sum", Binop(Sum, Deref(Id "sum"), Deref(Id "i")))),
                   Deref(Id "sum"))))
    "Teste FOR2 (soma de 1 a 1) - deve retornar 1";
    
  (* Teste com for de 5 a 2 (nao deve executar) *)
  teste_eval (Let("sum", TyRef TyInt, New(Num 10),
                Seq(For("i", Num 5, Num 2, 
                      Asg(Id "sum", Binop(Sum, Deref(Id "sum"), Deref(Id "i")))),
                   Deref(Id "sum"))))
    "Teste FOR3 (for 5 a 2) - nao deve executar, retorna 10";
    
  (* Teste com variavel no limite *)
  teste_eval (Let("n", TyInt, Num 4,
                Let("sum", TyRef TyInt, New(Num 0),
                  Seq(For("i", Num 1, Id "n", 
                        Asg(Id "sum", Binop(Sum, Deref(Id "sum"), Deref(Id "i")))),
                     Deref(Id "sum")))))
    "Teste FOR4 (soma de 1 a n=4) - deve retornar 10";
    
  (* Teste for com multiplicacao *)
  teste_eval (Let("fact", TyRef TyInt, New(Num 1),
                Seq(For("i", Num 1, Num 4, 
                      Asg(Id "fact", Binop(Mul, Deref(Id "fact"), Deref(Id "i")))),
                   Deref(Id "fact"))))
    "Teste FOR5 (fatorial de 4 usando for) - deve retornar 24";
    
  print_endline ""

(* Função para testes de print *)
let testes_print () =
  print_endline "=== TESTES DE PRINT ===";
  
  (* Testes basicos de impressao *)
  teste_eval (Print(Num 42))
    "Teste PRINT1 (print 42) - imprime inteiro";
  teste_eval (Print(Bool true))
    "Teste PRINT2 (print true) - imprime booleano";
  teste_eval (Print(Unit))
    "Teste PRINT3 (print ()) - imprime unit";
    
  (* Teste com expressoes *)
  teste_eval (Print(Binop(Sum, Num 10, Num 5)))
    "Teste PRINT4 (print (10+5)) - imprime resultado de expressao";
  teste_eval (Print(Binop(Lt, Num 5, Num 10)))
    "Teste PRINT5 (print (5<10)) - imprime resultado booleano";
    
  (* Teste com referencias *)
  teste_eval (Let("r", TyRef TyInt, New(Num 100), Print(Deref(Id "r"))))
    "Teste PRINT6 (print !r) - imprime valor da referencia";
    
  (* Teste de sequencia de prints *)
  teste_eval (Seq(Print(Num 1), 
             Seq(Print(Num 2), 
                Print(Num 3))))
    "Teste PRINT7 (sequencia de prints) - imprime 1, 2, 3";
    
  print_endline ""

(* ===== FUNCOES DE TESTE ORGANIZADAS (CONTINUACAO) ===== *)
(* Definições para testes interativos *)
let teste1 = eval (Num 42) estado_inicial
let teste2 = eval (Bool true) estado_inicial
let teste3 = eval Unit estado_inicial

(* ===== EXECUÇÃO PRINCIPAL DOS TESTES ===== *)
let () = 
  print_endline "=== INICIANDO BATERIA DE TESTES COMPLETA ===";
  print_endline "";
  
  testes_literais ();
  testes_aritmeticos ();
  testes_erros ();
  testes_logicos ();
  testes_referencias ();
  testes_deref ();
  testes_atribuicao ();
  testes_while ();
  testes_for ();
  testes_print ();
  
  print_endline "";
  print_endline "=== TODOS OS TESTES EXECUTADOS ==="
