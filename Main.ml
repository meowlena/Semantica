(* =====================================================
   AVALIADOR PRINCIPAL PARA A LINGUAGEM FUNCIONAL
   ===================================================== *)

(* Importa definições necessárias *)
open Datatypes
open Eval

(* ===== PROGRAMA PRINCIPAL ===== *)

let () = 
  print_endline "===============================================";
  print_endline "   AVALIADOR DA LINGUAGEM FUNCIONAL";
  print_endline "===============================================";
  print_endline "";
  print_endline "Executando programa de exemplo: Cálculo de Fatorial";
  print_endline "";
  print_endline "O programa irá ler um número da entrada e calcular seu fatorial.";
  print_endline "Programa: let input_number: int = read() in";
  print_endline "          let counter: ref int = new input_number in";  
  print_endline "          let accumulator: ref int = new 1 in";
  print_endline "          (while (!counter > 0) do (";
  print_endline "            accumulator := !accumulator * !counter;";
  print_endline "            counter := !counter - 1";
  print_endline "          )); print(!accumulator)";
  print_endline "";
  
  try
    (* Executa o programa de fatorial definido em Datatypes.ml *)
    let (resultado, estado_final) = eval factorial_program estado_inicial in
    print_endline "";
    print_endline "===============================================";
    print_endline "   EXECUÇÃO CONCLUÍDA";
    print_endline "===============================================";
    Printf.printf "Resultado: %s\n" (match resultado with
      | VInt n -> string_of_int n
      | VBool b -> string_of_bool b
      | VUnit -> "()"
      | VRef addr -> "ref@" ^ string_of_int addr);
    Printf.printf "Estado final - Próximo endereço: %d\n" estado_final.next_addr;
    Printf.printf "Memória utilizada: %d células\n" (List.length estado_final.mem);
  with
    | DivisaoPorZero -> 
        print_endline "ERRO: Divisão por zero durante a execução"
    | TiposIncompativeis msg -> 
        print_endline ("ERRO: Tipos incompatíveis - " ^ msg)
    | e -> 
        print_endline ("ERRO: " ^ (Printexc.to_string e))
