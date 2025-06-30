(* =====================================================
   TESTE DO FOR LOOP - SOMA DE 1 A N
   ===================================================== *)

(* Importa os módulos necessários *)
open Datatypes
open Eval

(* ===== PROGRAMA DE TESTE ===== *)

let () =
  print_endline "===============================================";
  print_endline "   TESTE DO FOR LOOP - SOMA DE 1 A N";
  print_endline "===============================================";
  print_endline "Digite um número N para calcular a soma de 1 até N:";
  print_endline "";
  print_endline "Programa: let n: int = read() in";
  print_endline "          let sum: ref int = new 0 in";
  print_endline "          for i = 1 to n do (";
  print_endline "            sum := !sum + i";
  print_endline "          ); print(!sum)";
  print_endline "";
  
  try
    (* Executa o programa de soma usando for *)
    let (resultado, estado_final) = eval for_sum_program estado_inicial in
    
    print_endline "";
    print_endline "===============================================";
    print_endline "   EXECUÇÃO CONCLUÍDA";
    print_endline "===============================================";
    Printf.printf "Resultado: %s\n" (string_of_valor resultado);
    Printf.printf "Estado final - Próximo endereço: %d\n" estado_final.next_addr;
    Printf.printf "Memória utilizada: %d células\n" (List.length estado_final.mem);
    
  with
  | DivisaoPorZero -> 
      print_endline "ERRO: Divisão por zero!";
      exit 1
  | TiposIncompativeis msg -> 
      Printf.printf "ERRO: %s\n" msg;
      exit 1
  | Failure msg -> 
      Printf.printf "ERRO: %s\n" msg;
      exit 1
  | exn -> 
      Printf.printf "ERRO inesperado: %s\n" (Printexc.to_string exn);
      exit 1

(* ===== FIM DO TESTE ===== *)
