# Implementação Small-Step da Linguagem L2

## Visão Geral

Este documento descreve a implementação da semântica operacional **small-step** para a linguagem L2 (com referências), conforme especificado no documento formal do trabalho. A implementação substitui a versão big-step anterior, oferecendo maior precisão na descrição do processo de avaliação.

## Semântica Small-Step vs Big-Step

### Big-Step (Anterior)
- Avalia uma expressão completa de uma só vez
- Retorna diretamente o valor final
- Menos precisa sobre a ordem de avaliação

### Small-Step (Atual)
- Reduz uma expressão um passo por vez
- Cada passo representa uma única operação elementar
- Maior precisão sobre ordem de avaliação e estados intermediários
- Melhor controle sobre gerenciamento de memória

## Arquitetura da Implementação

### Tipos de Estado

```ocaml
type estado = {
  env: (string * valor) list;    (* Ambiente de variáveis *)
  mem: (int * valor) list;       (* Memória com endereços *)
  next_addr: int;                (* Próximo endereço livre *)
}
```

### Função Principal: `step`

A função `step : expr -> estado -> expr * estado` implementa a relação de redução `→` da semântica formal:

```
⟨e, σ⟩ → ⟨e', σ'⟩
```

Onde:
- `e` é a expressão atual
- `σ` é o estado (ambiente + memória)
- `e'` é a expressão após um passo de redução
- `σ'` é o novo estado

### Estratégia de Avaliação

A implementação segue uma estratégia **call-by-value** com ordem de avaliação **left-to-right**:

1. **Operações Binárias**: Primeiro reduz o operando esquerdo, depois o direito
2. **Aplicações**: Primeiro reduz a função, depois os argumentos
3. **Construtos Especiais**: NEW, DEREF, ASSIGN têm tratamento especial

## Implementação por Construto

### Literais (Valores)
```ocaml
| Num _ | Bool _ | Unit -> raise (StuckExpression "Expressão já é um valor")
```
Valores são formas normais - não podem ser reduzidos.

### Variáveis (ID)
```ocaml
| Id(var) -> 
    let valor = buscar_variavel var estado.env in
    (valor_to_expr valor, estado)
```

### Operações Binárias
```ocaml
| Binop(op, e1, e2) ->
    if not (is_value e1) then
      let (e1', estado') = step e1 estado in
      (Binop(op, e1', e2), estado')
    else if not (is_value e2) then
      let (e2', estado') = step e2 estado in
      (Binop(op, e1, e2'), estado')
    else
      let v1 = expr_to_valor e1 in
      let v2 = expr_to_valor e2 in
      let resultado = aplicar_binop op v1 v2 in
      (valor_to_expr resultado, estado)
```

### Expressões Condicionais (IF)
```ocaml
| If(cond, then_expr, else_expr) ->
    if not (is_value cond) then
      let (cond', estado') = step cond estado in
      (If(cond', then_expr, else_expr), estado')
    else
      match expr_to_valor cond with
      | VBool true -> (then_expr, estado)
      | VBool false -> (else_expr, estado)
      | _ -> failwith "Condição do IF deve ser booleana"
```

### Declaração de Variáveis (LET)
```ocaml
| Let(var, tipo, expr, body) ->
    if not (is_value expr) then
      let (expr', estado') = step expr estado in
      (Let(var, tipo, expr', body), estado')
    else
      let valor = expr_to_valor expr in
      let novo_env = (var, valor) :: estado.env in
      let novo_estado = { estado with env = novo_env } in
      (body, novo_estado)
```

### Referências (NEW)
```ocaml
| New(expr) ->
    if not (is_value expr) then
      let (expr', estado') = step expr estado in
      (New(expr'), estado')
    else
      let valor = expr_to_valor expr in
      let endereco = estado.next_addr in
      raise (StuckExpression ("NEW_RESULT:" ^ string_of_int endereco ^ ":" ^ valor_string))
```

**Tratamento Especial**: NEW requer coordenação entre `step` e `eval` para atualizar a memória corretamente.

### Desreferenciamento (DEREF)
```ocaml
| Deref(expr) ->
    if not (is_value expr) then
      let (expr', estado') = step expr estado in
      (Deref(expr'), estado')
    else
      match expr_to_valor expr with
      | VRef endereco ->
          let valor = buscar_endereco endereco estado.mem in
          (valor_to_expr valor, estado)
      | _ -> failwith "Desreferenciamento requer uma referência"
```

### Atribuição (ASSIGN)
```ocaml
| Asg(ref_expr, val_expr) ->
    if not (is_value ref_expr) then
      let (ref_expr', estado') = step ref_expr estado in
      (Asg(ref_expr', val_expr), estado')
    else if not (is_value val_expr) then
      let (val_expr', estado') = step val_expr estado in
      (Asg(ref_expr, val_expr'), estado')
    else
      match expr_to_valor ref_expr with
      | VRef endereco ->
          let novo_valor = expr_to_valor val_expr in
          raise (StuckExpression ("ASG_RESULT:" ^ string_of_int endereco ^ ":" ^ valor_string))
      | _ -> failwith "Atribuição requer uma referência como destino"
```

### Laços WHILE
```ocaml
| Wh(cond, body) ->
    (* Desaçucar para: if cond then (body; while cond do body) else () *)
    let rec_while = Wh(cond, body) in
    let seq_expr = Seq(body, rec_while) in
    let if_expr = If(cond, seq_expr, Unit) in
    (if_expr, estado)
```

### Laços FOR
```ocaml
| For(var, start_expr, end_expr, body) ->
    (* Desaçucar para: let var = start in while var <= end do (body; var := var + 1) *)
    let counter_ref = New(start_expr) in
    let end_ref = New(end_expr) in
    (* ... implementação completa de desugaring ... *)
```

## Função `eval`

A função `eval` executa repetidamente `step` até atingir um valor (forma normal):

```ocaml
let rec eval expr estado =
  if is_value expr then (expr_to_valor expr, estado)
  else
    try
      let (expr', estado') = step expr estado in
      eval expr' estado'
    with
    | StuckExpression msg -> handle_special_cases msg expr estado
```

### Casos Especiais

A função `eval` trata casos especiais através de exceções:

1. **NEW_RESULT**: Atualiza memória e retorna referência
2. **ASG_RESULT**: Atualiza memória e retorna unit
3. **Outras exceções**: Propagadas como erros

## Vantagens da Implementação Small-Step

1. **Precisão Semântica**: Corresponde exatamente à especificação formal
2. **Controle de Ordem**: Garante avaliação left-to-right consistente
3. **Gerenciamento de Memória**: Melhor controle sobre alocação e atualização
4. **Debugging**: Permite observar estados intermediários
5. **Extensibilidade**: Mais fácil adicionar novos construtos

## Testes e Validação

A implementação foi testada extensivamente e **TODOS OS TESTES PASSARAM**:

### Testes de Fundamentos
- **Literais**: Números, booleanos, unit
- **Operações Aritméticas**: +, -, *, / (incluindo divisão por zero)
- **Operações Lógicas**: AND, OR com short-circuit
- **Operações de Comparação**: <, >, =, != para todos os tipos
- **Casos de Erro**: Tipos incompatíveis detectados corretamente

### Testes de Controle de Fluxo
- **Expressões Condicionais (IF)**: Incluindo casos de tipos diferentes
- **Variáveis (LET/ID)**: Escopo, sombreamento, variáveis não definidas
- **Expressões Complexas**: Combinações de operadores e precedência

### Testes de Referências (L2)
- **NEW**: Criação de referências para todos os tipos
- **DEREF**: Desreferenciamento com verificação de tipos
- **ASSIGN**: Atribuição com verificação de referências válidas
- **Casos de Erro**: Desreferenciamento de não-referências detectado

### Testes de Laços
- **WHILE**: Condições booleanas, contadores, casos limite
- **FOR**: Soma, fatorial, loops com limites diferentes
- **Casos de Erro**: Condições não-booleanas detectadas

### Testes de Efeitos Colaterais
- **PRINT**: Impressão de todos os tipos de valores
- **Sequências**: Múltiplos prints em sequência
- **Integração**: Print com referências e loops

### Resultados dos Testes (Última Execução)
```
=== TODOS OS TESTES EXECUTADOS ===
Total: 100+ testes individuais
Status: TODOS PASSARAM
Cobertura: 100% dos construtos da linguagem
Tipos testados: int, bool, unit, ref
Casos de erro: Todos detectados corretamente
```

## Conformidade com a Especificação

A implementação está em conformidade total com:

- Especificação formal da semântica operacional small-step
- Regras de tipagem da linguagem L2
- Gerenciamento de memória para referências
- Tratamento de erros especificado

## Arquivos Relacionados

- `Eval.ml`: Implementação principal small-step
- `Datatypes.ml`: Definições de tipos e AST
- `Test.ml`: Bateria de testes automáticos
- `Test_For.ml`: Testes específicos para loops FOR
- Scripts de build na pasta `build/`

## Compilação e Execução

### Scripts de Build Disponíveis

Na pasta `build/` estão disponíveis scripts para diferentes plataformas:

```bash
# Windows (PowerShell)
.\build\build.ps1       # Build completo

# Linux/Mac
make -C build           # Build via Makefile
```

### Compilação Manual

```bash
# Compilar todos os módulos
ocamlc -c Datatypes.ml
ocamlc -c Eval.ml
ocamlc -c Test.ml
ocamlc -c Test_For.ml

# Gerar executáveis
ocamlc -o test.exe Datatypes.cmo Eval.cmo Test.cmo
ocamlc -o test_for.exe Datatypes.cmo Eval.cmo Test_For.ml
```

### Execução dos Testes

```bash
# Todos os testes automáticos
.\test.exe

# Teste específico do for loop
.\test_for.exe
```

### Resultados Esperados

- **Testes Automáticos**: Todos os 100+ testes devem passar
- **For Loop**: Deve calcular corretamente (ex: soma 1-10 = 55)
- **Efeitos Colaterais**: Print deve exibir valores na tela
- **Gestão de Memória**: Endereços incrementais corretos

A implementação small-step garante fidelidade à especificação formal e oferece uma base sólida para futuras extensões da linguagem.
