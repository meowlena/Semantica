# Makefile para o projeto de Semantica Formal

# Compilador OCaml
OCAMLC = ocamlc

# Arquivos fonte
SOURCES = Datatypes.ml Eval.ml Test.ml
OBJECTS = $(SOURCES:.ml=.cmo)

# Alvos principais
all: avaliador testes

# Compilar o avaliador (sem executar os testes)
avaliador: Datatypes.cmo Eval.cmo
	$(OCAMLC) -o avaliador Datatypes.cmo Eval.cmo

# Compilar e linkar testes
testes: $(OBJECTS)
	$(OCAMLC) -o testes $(OBJECTS)

# Compilar módulos individuais
Datatypes.cmo: Datatypes.ml
	$(OCAMLC) -c $<

Eval.cmo: Eval.ml Datatypes.cmo
	$(OCAMLC) -c $<

Test.cmo: Test.ml Datatypes.cmo Eval.cmo
	$(OCAMLC) -c $<

# Limpar arquivos compilados
clean:
	rm -f *.cmi *.cmo avaliador testes

# Regras para Windows (PowerShell)
win-clean:
	powershell "Remove-Item -Force *.cmi, *.cmo, avaliador.exe, testes.exe -ErrorAction SilentlyContinue"

.PHONY: all clean win-clean avaliador testes
