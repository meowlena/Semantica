# Instruções de Compilação

Este projeto mantém todos os scripts de compilação separados da implementação principal, na pasta `build/`.

## Método Recomendado

Para compilar o projeto, use os scripts da pasta build:

```bash
# Para compilar usando Make (requer estar na pasta build)
cd build && make    # Precisa entrar na pasta build

# Alternativa usando scripts
.\build\compile.bat  # Windows (CMD ou PowerShell)
./build/compile.sh   # Unix/Linux/WSL/Cygwin
```

## Estrutura de Arquivos de Compilação

Todos os arquivos relacionados à compilação estão na pasta `build/`:

- `build/Makefile`: Principal script de compilação com Make
- `build/compile.bat`: Script unificado para Windows
- `build/compile.sh`: Script unificado para Unix/Linux
- `build/build.ps1`: Script auxiliar para PowerShell
- `build/build.sh`: Script auxiliar para Unix/Linux
- `build/README.md`: Documentação específica dos scripts de compilação

## Como Funciona

Os scripts detectam automaticamente o ambiente (Windows CMD, PowerShell, Unix) e 
usam o método apropriado de compilação. A compilação ocorre em 5 passos:

1. Compilação de Datatypes.ml
2. Compilação de Eval.ml
3. Compilação de Test.ml
4. Criação do executável avaliador
5. Criação do executável de testes

## Executando o Projeto

Após a compilação, você terá dois executáveis na raiz do projeto:

- `avaliador`: O avaliador principal
- `testes`: Os testes do avaliador

Execute-os com:

```bash
# Em qualquer plataforma:
.\avaliador  # No Windows (CMD/PowerShell)
.\avaliador.exe  # No Windows (alternativa com extensão)
./avaliador  # No Unix/Linux

.\testes     # No Windows (CMD/PowerShell)
.\testes.exe # No Windows (alternativa com extensão)
./testes     # No Unix/Linux
```

## Comandos Make

Se você usa o Make, pode usar comandos específicos:

```bash
make            # Compila tudo
make clean      # Limpa arquivos compilados (Unix)
make win-clean  # Limpa arquivos compilados (Windows)
make avaliador  # Compila apenas o avaliador
make testes     # Compila os testes
```
