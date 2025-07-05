(* =====================================================
   BATERIA COMPLETA DE TESTES PARA O AVALIADOR SMALL-STEP
   ===================================================== *)

(* Este arquivo contem testes abrangentes para validar o avaliador small-step
   da linguagem L2 com referencias. Todos os testes foram atualizados para
   usar o novo estado com input_buffer e a semantica small-step pura. *)

open Datatypes
open Eval

(* ===== FUNCOES AUXILIARES PARA TESTES ===== *)

(* Funcao para executar teste simples (sem input) *)
let teste_eval expr nome =
  Printf.printf "\n--- %s ---\n" nome;
  try
    let (valor, estado_final) = eval expr estado_inicial in
    Printf.printf "OK Resultado: %s\n" (string_of_valor valor);
    if estado_final.mem <> [] then (
      Printf.printf "Memória final:\n";
      List.iter (fun (addr, val_mem) ->
        Printf.printf "  [%d] -> %s\n" addr (string_of_valor val_mem)
      ) estado_final.mem
    )
  with
  | DivisaoPorZero -> Printf.printf "ERRO: Divisao por zero\n"
  | TiposIncompativeis msg -> Printf.printf "ERRO: %s\n" msg
  | exn -> Printf.printf "ERRO: %s\n" (Printexc.to_string exn)

(* Funcao para executar teste com input *)
let teste_eval_com_input expr nome inputs =
  Printf.printf "\n--- %s (input: %s) ---\n" nome 
    (String.concat ", " (List.map string_of_int inputs));
  try
    let estado_com_input = estado_com_entradas inputs in
    let (valor, estado_final) = eval expr estado_com_input in
    Printf.printf "OK Resultado: %s\n" (string_of_valor valor);
    if estado_final.mem <> [] then (
      Printf.printf "Memória final:\n";
      List.iter (fun (addr, val_mem) ->
        Printf.printf "  [%d] -> %s\n" addr (string_of_valor val_mem)
      ) estado_final.mem
    );
    if estado_final.input_buffer <> [] then (
      Printf.printf "Input restante: %s\n" 
        (String.concat ", " (List.map string_of_int estado_final.input_buffer))
    )
  with
  | DivisaoPorZero -> Printf.printf "ERRO: Divisao por zero\n"
  | TiposIncompativeis msg -> Printf.printf "ERRO: %s\n" msg
  | exn -> Printf.printf "ERRO: %s\n" (Printexc.to_string exn)

(* ===== TESTES DE VALORES BÁSICOS ===== *)

let testes_valores_basicos () =
  print_endline "\n========== TESTES DE VALORES BÁSICOS ==========";
  
  teste_eval (Num 42) "Literal inteiro";
  teste_eval (Num (-15)) "Literal inteiro negativo";
  teste_eval (Bool true) "Literal booleano true";
  teste_eval (Bool false) "Literal booleano false";
  teste_eval Unit "Valor unit"

(* ===== TESTES DE OPERAÇÕES ARITMÉTICAS ===== *)

let testes_aritmeticos () =
  print_endline "\n========== TESTES ARITMÉTICOS ==========";
  
  teste_eval (Binop(Sum, Num 10, Num 5)) "Soma: 10 + 5";
  teste_eval (Binop(Sub, Num 10, Num 3)) "Subtracao: 10 - 3";
  teste_eval (Binop(Mul, Num 7, Num 6)) "Multiplicacao: 7 * 6";
  teste_eval (Binop(Div, Num 20, Num 4)) "Divisao: 20 / 4";
  
  (* Teste de divisao por zero *)
  teste_eval (Binop(Div, Num 10, Num 0)) "Divisao por zero (deve dar erro)";
  
  (* Operacoes aninhadas *)
  teste_eval (Binop(Sum, Binop(Mul, Num 3, Num 4), Num 2)) "Aninhada: (3 * 4) + 2"

(* ===== TESTES DE OPERAÇÕES LÓGICAS ===== *)

let testes_logicos () =
  print_endline "\n========== TESTES LÓGICOS ==========";
  
  teste_eval (Binop(And, Bool true, Bool true)) "AND: true && true";
  teste_eval (Binop(And, Bool true, Bool false)) "AND: true && false";
  teste_eval (Binop(Or, Bool false, Bool true)) "OR: false || true";
  teste_eval (Binop(Or, Bool false, Bool false)) "OR: false || false";
  
  (* Teste de curto-circuito *)
  teste_eval (Binop(And, Bool false, Binop(Div, Num 1, Num 0))) 
    "Curto-circuito AND (não deve dar erro)";
  teste_eval (Binop(Or, Bool true, Binop(Div, Num 1, Num 0))) 
    "Curto-circuito OR (não deve dar erro)"

(* ===== TESTES DE COMPARAÇÃO ===== *)

let testes_comparacao () =
  print_endline "\n========== TESTES DE COMPARAÇÃO ==========";
  
  teste_eval (Binop(Lt, Num 5, Num 10)) "Menor que: 5 < 10";
  teste_eval (Binop(Gt, Num 15, Num 8)) "Maior que: 15 > 8";
  teste_eval (Binop(Eq, Num 7, Num 7)) "Igualdade: 7 = 7";
  teste_eval (Binop(Neq, Num 5, Num 3)) "Diferenca: 5 != 3";
  
  (* Comparações booleanas *)
  teste_eval (Binop(Eq, Bool true, Bool true)) "Igualdade booleana: true = true";
  teste_eval (Binop(Neq, Bool true, Bool false)) "Diferenca booleana: true != false"

(* ===== TESTES DE IF-THEN-ELSE ===== *)

let testes_condicionais () =
  print_endline "\n========== TESTES CONDICIONAIS ==========";
  
  teste_eval (If(Bool true, Num 100, Num 200)) "IF com true";
  teste_eval (If(Bool false, Num 100, Num 200)) "IF com false";
  teste_eval (If(Binop(Lt, Num 5, Num 10), Num 1, Num 0)) "IF com comparação";
  
  (* IF aninhado *)
  teste_eval (If(Bool true, 
                 If(Bool false, Num 1, Num 2), 
                 Num 3)) "IF aninhado"

(* ===== TESTES DE LET ===== *)

let testes_let () =
  print_endline "\n========== TESTES DE LET ==========";
  
  teste_eval (Let("x", TyInt, Num 42, Id "x")) "LET simples";
  teste_eval (Let("x", TyInt, Num 10, 
                  Binop(Sum, Id "x", Num 5))) "LET com uso da variável";
  
  (* LET aninhado *)
  teste_eval (Let("x", TyInt, Num 5,
                  Let("y", TyInt, Num 10,
                      Binop(Sum, Id "x", Id "y")))) "LET aninhado";
  
  (* Teste de escopo *)
  teste_eval (Let("x", TyInt, Num 5,
                  Let("x", TyInt, Num 10,
                      Id "x"))) "Teste de escopo (shadowing)"

(* ===== TESTES DE SEQUENCIAMENTO ===== *)

let testes_sequenciamento () =
  print_endline "\n========== TESTES DE SEQUENCIAMENTO ==========";
  
  teste_eval (Seq(Num 1, Num 2)) "Sequência simples";
  teste_eval (Seq(Seq(Num 1, Num 2), Num 3)) "Sequência aninhada";
  teste_eval (Seq(Print(Num 42), Num 100)) "Sequência com print"

(* ===== TESTES DE PRINT ===== *)

let testes_print () =
  print_endline "\n========== TESTES DE PRINT ==========";
  
  (* Print de valores básicos *)
  teste_eval (Print(Num 42)) "Print de número";
  teste_eval (Print(Bool true)) "Print de booleano true";
  teste_eval (Print(Bool false)) "Print de booleano false";
  teste_eval (Print(Unit)) "Print de unit";
  
  (* Print de expressões *)
  teste_eval (Print(Binop(Sum, Num 10, Num 5))) "Print de soma";
  teste_eval (Print(If(Bool true, Num 100, Num 200))) "Print de condicional";
  
  (* Múltiplos prints em sequência *)
  teste_eval (Seq(Print(Num 1), Print(Num 2))) "Dois prints em sequencia";
  teste_eval (Seq(Seq(Print(Num 1), Print(Num 2)), Print(Num 3))) 
    "Tres prints em sequencia";
  
  (* Print com variáveis *)
  teste_eval (Let("x", TyInt, Num 42, Print(Id "x"))) "Print de variavel";
  
  (* Print com referências *)
  teste_eval (Let("r", TyRef TyInt, New(Num 99),
                  Print(Deref(Id "r")))) "Print de dereferencia";
  
  (* Print aninhado com outras operações *)
  teste_eval (Let("x", TyInt, Num 10,
                  Seq(Print(Id "x"),
                      Let("y", TyInt, Binop(Mul, Id "x", Num 2),
                          Print(Id "y"))))) "Print aninhado com let";
  
  (* Print dentro de estruturas de controle *)
  teste_eval (If(Bool true, Print(Num 1), Print(Num 0))) "Print em if-then-else"

(* ===== TESTES DE REFERÊNCIAS ===== *)

let testes_referencias () =
  print_endline "\n========== TESTES DE REFERÊNCIAS ==========";
  
  (* NEW básico *)
  teste_eval (New(Num 42)) "NEW simples";
  teste_eval (New(Bool true)) "NEW com booleano";
  
  (* NEW + DEREF *)
  teste_eval (Deref(New(Num 100))) "NEW + DEREF";
  
  (* Múltiplas referências *)
  teste_eval (Let("r1", TyRef TyInt, New(Num 10),
                  Let("r2", TyRef TyInt, New(Num 20),
                      Binop(Sum, Deref(Id "r1"), Deref(Id "r2"))))) 
    "Multiplas referencias";
  
  (* Atribuição básica *)
  teste_eval (Let("r", TyRef TyInt, New(Num 5),
                  Seq(Asg(Id "r", Num 15),
                      Deref(Id "r")))) "Atribuicao basica";
  
  (* Múltiplas atribuições *)
  teste_eval (Let("r", TyRef TyInt, New(Num 0),
                  Seq(Asg(Id "r", Num 10),
                      Seq(Asg(Id "r", Num 20),
                          Deref(Id "r"))))) "Multiplas atribuicoes"

(* ===== TESTES DE READ ===== *)

let testes_read () =
  print_endline "\n========== TESTES DE READ ==========";
  
  teste_eval_com_input Read "Read simples" [42];
  teste_eval_com_input (Binop(Sum, Read, Num 10)) "Read + operação" [5];
  teste_eval_com_input (Let("x", TyInt, Read, 
                            Binop(Mul, Id "x", Num 2))) "Read em LET" [7];
  
  (* Múltiplos reads *)
  teste_eval_com_input (Binop(Sum, Read, Read)) "Dois reads" [3; 7];
  
  (* Read com buffer vazio (deve retornar 0) *)
  teste_eval Read "Read sem input (buffer vazio)"

(* ===== TESTES DE WHILE ===== *)

let testes_while () =
  print_endline "\n========== TESTES DE WHILE ==========";
  
  (* While que não executa *)
  teste_eval (Wh(Bool false, Print(Num 999))) "While que nao executa";
  
  (* Contador simples *)
  teste_eval (Let("counter", TyRef TyInt, New(Num 3),
                  Seq(Wh(Binop(Gt, Deref(Id "counter"), Num 0),
                         Asg(Id "counter", Binop(Sub, Deref(Id "counter"), Num 1))),
                      Deref(Id "counter")))) "Contador decrescente";
  
  (* Acumulador *)
  teste_eval (Let("i", TyRef TyInt, New(Num 1),
                  Let("sum", TyRef TyInt, New(Num 0),
                      Seq(Wh(Binop(Lt, Deref(Id "i"), Num 4),
                             Seq(Asg(Id "sum", Binop(Sum, Deref(Id "sum"), Deref(Id "i"))),
                                 Asg(Id "i", Binop(Sum, Deref(Id "i"), Num 1)))),
                          Deref(Id "sum"))))) "Soma 1+2+3"

(* ===== TESTES DE FOR ===== *)

let testes_for () =
  print_endline "\n========== TESTES DE FOR ==========";
  
  (* FOR simples *)
  teste_eval (For("i", Num 1, Num 3, Print(Id "i"))) "FOR simples (print 1,2,3)";
  
  (* FOR com acumulador *)
  teste_eval (Let("sum", TyRef TyInt, New(Num 0),
                  Seq(For("i", Num 1, Num 5,
                          Asg(Id "sum", Binop(Sum, Deref(Id "sum"), Id "i"))),
                      Deref(Id "sum")))) "FOR soma 1 a 5";
  
  (* FOR com multiplicação *)
  teste_eval (Let("prod", TyRef TyInt, New(Num 1),
                  Seq(For("i", Num 1, Num 4,
                          Asg(Id "prod", Binop(Mul, Deref(Id "prod"), Id "i"))),
                      Deref(Id "prod")))) "FOR produto 1*2*3*4 (fatorial de 4)"

(* ===== TESTES DE PROGRAMAS COMPLEXOS ===== *)

let testes_programas_complexos () =
  print_endline "\n========== TESTES DE PROGRAMAS COMPLEXOS ==========";
  
  (* Fatorial usando while *)
  teste_eval_com_input factorial_program "Programa fatorial" [5];
  
  (* Soma usando for *)
  teste_eval_com_input for_sum_program "Programa soma com FOR" [10];
  
  (* Programa que testa escopo e referências *)
  teste_eval (Let("x", TyInt, Num 100,
                  Let("y", TyRef TyInt, New(Id "x"),
                      Let("x", TyInt, Num 200,
                          Binop(Sum, Id "x", Deref(Id "y")))))) "Escopo complexo"

(* ===== TESTES DE CASOS EXTREMOS ===== *)

let testes_casos_extremos () =
  print_endline "\n========== TESTES DE CASOS EXTREMOS ==========";
  
  (* FOR com range vazio *)
  teste_eval (For("i", Num 5, Num 2, Print(Id "i"))) "FOR com range vazio";
  
  (* FOR com range unitário *)
  teste_eval (For("i", Num 3, Num 3, Print(Id "i"))) "FOR com range unitário";
  
  (* Referência de referência (não suportado diretamente, mas teste interessante) *)
  teste_eval (Let("r1", TyRef TyInt, New(Num 42),
                  Let("addr", TyInt, Num 0,  (* Simula endereço *)
                      Deref(Id "r1")))) "Teste de referência complexa"

(* ===== FUNÇÃO PRINCIPAL DOS TESTES ===== *)

let executar_todos_os_testes () =
  print_endline "INICIANDO BATERIA COMPLETA DE TESTES DO AVALIADOR SMALL-STEP";
  print_endline "==================================================================";
  
  testes_valores_basicos ();
  testes_aritmeticos ();
  testes_logicos ();
  testes_comparacao ();
  testes_condicionais ();
  testes_let ();
  testes_sequenciamento ();
  testes_print ();
  testes_referencias ();
  testes_read ();
  testes_while ();
  testes_for ();
  testes_programas_complexos ();
  testes_casos_extremos ();
  
  print_endline "\n==================================================================";
  print_endline "BATERIA DE TESTES CONCLUIDA!";
  print_endline "   Se nao houve erros acima, o avaliador esta funcionando corretamente.";
  print_endline "   Implementacao small-step validada com sucesso!"

(* ===== SISTEMA DE EXECUÇÃO MODULAR ===== *)

let mostrar_ajuda () =
  print_endline "=== SISTEMA DE TESTES MODULAR ===";
  print_endline "Uso: ./test [opção]";
  print_endline "";
  print_endline "Opções disponíveis:";
  print_endline "  all              - Executa todos os testes (padrão)";
  print_endline "  basicos          - Testes de valores básicos";
  print_endline "  aritmeticos      - Testes de operações aritméticas";
  print_endline "  logicos          - Testes de operações lógicas";
  print_endline "  comparacao       - Testes de comparação";
  print_endline "  condicionais     - Testes de if-then-else";
  print_endline "  let              - Testes de let";
  print_endline "  sequenciamento   - Testes de sequenciamento";
  print_endline "  print            - Testes especificos de Print";
  print_endline "  referencias      - Testes de referencias";
  print_endline "  read             - Testes de Read";
  print_endline "  while            - Testes de While";
  print_endline "  for              - Testes de For";
  print_endline "  complexos        - Testes de programas complexos";
  print_endline "  extremos         - Testes de casos extremos";
  print_endline "  help             - Mostra esta ajuda";
  print_endline ""

let executar_teste_especifico teste =
  print_endline "EXECUTANDO TESTE ESPECIFICO";
  print_endline "===============================";
  
  (match teste with
   | "basicos" -> testes_valores_basicos ()
   | "aritmeticos" -> testes_aritmeticos ()
   | "logicos" -> testes_logicos ()
   | "comparacao" -> testes_comparacao ()
   | "condicionais" -> testes_condicionais ()
   | "let" -> testes_let ()
   | "sequenciamento" -> testes_sequenciamento ()
   | "print" -> testes_print ()
   | "referencias" -> testes_referencias ()
   | "read" -> testes_read ()
   | "while" -> testes_while ()
   | "for" -> testes_for ()
   | "complexos" -> testes_programas_complexos ()
   | "extremos" -> testes_casos_extremos ()
   | "all" -> executar_todos_os_testes (); exit 0
   | "help" -> mostrar_ajuda (); exit 0
   | _ -> 
       Printf.printf "ERRO: Teste '%s' nao reconhecido.\n" teste;
       print_endline "Use 'help' para ver as opcoes disponiveis.";
       exit 1);
  
  print_endline "\n===============================";
  Printf.printf "TESTE '%s' CONCLUIDO!\n" (String.uppercase_ascii teste)

(* ===== EXECUÇÃO COM ARGUMENTOS DE LINHA DE COMANDO ===== *)

let () =
  let args = Array.to_list Sys.argv in
  match args with
  | [_] -> 
      (* Sem argumentos - executa todos os testes *)
      executar_todos_os_testes ()
  | [_; teste] -> 
      (* Um argumento - executa teste específico *)
      executar_teste_especifico teste
  | _ -> 
      (* Muitos argumentos - mostra erro *)
      print_endline "ERRO: Muitos argumentos.";
      mostrar_ajuda ();
      exit 1