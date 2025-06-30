# Makefile para o projeto de Semantica Formal

# Caminho para o diretório raiz do projeto
ROOT_DIR = ..

# Compilador OCaml
OCAMLC = ocamlc

# Arquivos fonte (com caminho relativo)
SOURCES = $(ROOT_DIR)/Datatypes.ml $(ROOT_DIR)/Eval.ml $(ROOT_DIR)/Main.ml $(ROOT_DIR)/Test.ml $(ROOT_DIR)/Test_For.ml
OBJECTS = $(notdir $(SOURCES:.ml=.cmo))

# Diretório de trabalho
.PHONY: set-workdir
set-workdir:
	cd $(ROOT_DIR)

# Alvos principais
all: set-workdir avaliador testes test_for

# Compilar o avaliador (com Main.ml)
avaliador: $(ROOT_DIR)/Datatypes.cmo $(ROOT_DIR)/Eval.cmo $(ROOT_DIR)/Main.cmo
	cd $(ROOT_DIR) && $(OCAMLC) -o avaliador Datatypes.cmo Eval.cmo Main.cmo

# Compilar e linkar testes
testes: $(ROOT_DIR)/Datatypes.cmo $(ROOT_DIR)/Eval.cmo $(ROOT_DIR)/Test.cmo
	cd $(ROOT_DIR) && $(OCAMLC) -o testes Datatypes.cmo Eval.cmo Test.cmo

# Compilar e linkar teste do for loop
test_for: $(ROOT_DIR)/Datatypes.cmo $(ROOT_DIR)/Eval.cmo $(ROOT_DIR)/Test_For.cmo
	cd $(ROOT_DIR) && $(OCAMLC) -o test_for Datatypes.cmo Eval.cmo Test_For.cmo

# Compilar módulos individuais
$(ROOT_DIR)/Datatypes.cmo: $(ROOT_DIR)/Datatypes.ml
	cd $(ROOT_DIR) && $(OCAMLC) -c Datatypes.ml

$(ROOT_DIR)/Eval.cmo: $(ROOT_DIR)/Eval.ml $(ROOT_DIR)/Datatypes.cmo
	cd $(ROOT_DIR) && $(OCAMLC) -c Eval.ml

$(ROOT_DIR)/Main.cmo: $(ROOT_DIR)/Main.ml $(ROOT_DIR)/Datatypes.cmo $(ROOT_DIR)/Eval.cmo
	cd $(ROOT_DIR) && $(OCAMLC) -c Main.ml

$(ROOT_DIR)/Test.cmo: $(ROOT_DIR)/Test.ml $(ROOT_DIR)/Datatypes.cmo $(ROOT_DIR)/Eval.cmo
	cd $(ROOT_DIR) && $(OCAMLC) -c Test.ml

$(ROOT_DIR)/Test_For.cmo: $(ROOT_DIR)/Test_For.ml $(ROOT_DIR)/Datatypes.cmo $(ROOT_DIR)/Eval.cmo
	cd $(ROOT_DIR) && $(OCAMLC) -c Test_For.ml

# Limpar arquivos compilados
clean:
	cd $(ROOT_DIR) && rm -f *.cmi *.cmo avaliador avaliador.tmp testes testes.tmp test_for test_for.tmp

# Regras para Windows (PowerShell)
win-clean:
	cd $(ROOT_DIR) && powershell "Remove-Item -Force *.cmi, *.cmo, avaliador, avaliador.exe, avaliador.tmp, avaliador.tmp.exe, testes, testes.exe, testes.tmp, testes.tmp.exe, test_for, test_for.exe, test_for.tmp, test_for.tmp.exe -ErrorAction SilentlyContinue"

.PHONY: all clean win-clean avaliador testes test_for
