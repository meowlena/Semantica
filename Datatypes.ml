type bop =  
  | Sum | Sub | Mul | Div   (* operações aritméticas *)
  | Eq  | Neq | Lt | Gt   (* operações relacionais  *)
  | And | Or   (* operações lógicas *) 

type tipo = 
  | TyInt
  | TyBool
  | TyRef of tipo
  | TyUnit
    

type expr = 
  | Num of int
  | Bool of bool 
  | Id of string
  | If of expr * expr * expr 
  | Binop of bop * expr * expr
  | Wh of expr * expr 
  | Asg of expr * expr 
  | Let of string * tipo * expr * expr 
  | New of expr
  | Deref of expr 
  | Unit
  | Seq of expr * expr
  | Read
  | Print of expr
  
      

          
          (*         
           Programa exemplo: Cálculo de fatorial
           
           let input_number: int = read() in 
           let counter: ref int = new input_number in 
           let accumulator: ref int = new 1 in 
           
           (while (!counter > 0) (
                  accumulator := !accumulator * !counter;
                  counter := !counter - 1);
           print (!accumulator))     

*)



let while_condition = Binop(Gt, Deref (Id "counter"),Num 0)
let update_accumulator = Asg(Id "accumulator", Binop(Mul, Deref (Id "accumulator"),Deref(Id "counter")))
let decrement_counter = Asg(Id "counter", Binop(Sub, Deref (Id "counter"),Num 1))
let while_body = Seq(update_accumulator, decrement_counter) 
let factorial_loop = Wh(while_condition, while_body)
let print_result = Print(Deref (Id "accumulator"))
let loop_and_print = Seq(factorial_loop, print_result)
    
let factorial_program = Let("input_number", TyInt, Read, 
              Let("counter", TyRef TyInt, New (Id "input_number"), 
                  Let("accumulator", TyRef TyInt, New (Num 1),
                      loop_and_print)))
        
  
  
    
