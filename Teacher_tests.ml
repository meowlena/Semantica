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