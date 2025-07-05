open Datatypes
open Eval

let ex1 =
  Let("x",TyRef(TyInt), New(Num(3)), 
    Seq( 
      Asg(Id("x") , Binop(Sum,Read,Num(1))),
      Print(Deref(Id("x")))   
    )
  );;

            
let ex2 =
 Let("x",TyBool, Bool(true), 
  Seq(
    Let("x",TyInt, Num(3), 
      Print(Binop(Sum,Id("x"),Num(1)))
    )
  ,
    Id("x")
  )
)   
;;


let ex3 = 
  If(Binop(Lt,Num(3),Num(5)),
    Bool(true),
    Unit);;

let ex4 =
  Let("x",TyInt,Num(4),
    Let("y",TyRef TyInt,New(Num(0)),
      Let("a",TyRef TyInt,New(Num(0)),
        Wh(Binop(Lt,Deref(Id("y")),Id("x")),
          Seq(
            Asg(Id("y"),Binop(Sum,Deref(Id("y")),Num(1)))
          , 
            Asg(Id("a"),Binop(Sum,Deref(Id("a")),Deref(Id("y"))))
          )
        )
      )
    )
  );;

let ex5 =
  Let ("y", TyRef TyBool, New(Bool(true)),
    If( 
      Binop(Lt,Deref(New(Num(5))), Num(2)),
        New(Bool(false)),
        Id("y")
    )
  );;


let ex6 =
  Let("x",TyRef TyInt, New(Num(0)),
    Let("a",TyRef TyInt,New(Num(1)),
    Seq(
        Asg(Id("x"), Read)
      ,
      Seq(
        Wh(
          Binop(Neq, Deref(Id("x")), Num(0) )
          ,
          Seq(
            Asg(Id("a"),Binop(Mul,Deref(Id("a")),Deref(Id("x"))))
            ,
            Asg(Id("x"),Binop(Sub,Deref(Id("x")),Num(1)))
          )
        ) 
      ,
        Print(Deref(Id("a")))
      )
    )
    )
  );;

(* ===== FUNCAO PARA EXECUTAR TODOS OS EXEMPLOS DO PROFESSOR ===== *)

let executar_exemplo expr nome input_opt =
  Printf.printf "\n=== %s ===\n" nome;
  try
    let estado = match input_opt with
      | None -> estado_inicial
      | Some inputs -> estado_com_entradas inputs
    in
    let (valor, estado_final) = eval expr estado in
    Printf.printf "OK Resultado: %s\n" (string_of_valor valor);
    
    (* Mostrar memoria final se nao estiver vazia *)
    if estado_final.mem <> [] then (
      Printf.printf "Memoria final:\n";
      List.iter (fun (addr, val_mem) ->
        Printf.printf "  [%d] -> %s\n" addr (string_of_valor val_mem)
      ) estado_final.mem
    ) else (
      Printf.printf "Memoria final: vazia\n"
    );
    
    (* Mostrar input restante se houver *)
    if estado_final.input_buffer <> [] then (
      Printf.printf "Input restante: %s\n" 
        (String.concat ", " (List.map string_of_int estado_final.input_buffer))
    )
  with
  | DivisaoPorZero -> Printf.printf "ERRO: Divisao por zero\n"
  | TiposIncompativeis msg -> Printf.printf "ERRO: %s\n" msg
  | exn -> Printf.printf "ERRO: %s\n" (Printexc.to_string exn)

let executar_todos_exemplos () =
  print_endline "EXECUTANDO EXEMPLOS DO PROFESSOR";
  print_endline "===================================";
  
  (* ex1 precisa de input para o Read *)
  executar_exemplo ex1 "Exemplo 1: Referencia + Read + Print" (Some [7]);
  
  (* ex2 nao precisa de input *)
  executar_exemplo ex2 "Exemplo 2: Escopo de variaveis + Print" None;
  
  (* ex3 nao precisa de input *)
  executar_exemplo ex3 "Exemplo 3: Condicional simples" None;
  
  (* ex4 nao precisa de input *)
  executar_exemplo ex4 "Exemplo 4: Loop While com contadores" None;
  
  (* ex5 nao precisa de input *)
  executar_exemplo ex5 "Exemplo 5: Referencias aninhadas" None;
  
  (* ex6 precisa de input para o Read *)
  executar_exemplo ex6 "Exemplo 6: Fatorial com Read e While" (Some [5]);
  
  print_endline "\n===================================";
  print_endline "TODOS OS EXEMPLOS EXECUTADOS!";
  print_endline "Se nao ha erros acima, todos os testes passaram com sucesso!"

(* ===== EXECUÇÃO AUTOMÁTICA ===== *)

let () = executar_todos_exemplos ()