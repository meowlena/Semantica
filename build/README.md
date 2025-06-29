# Scripts de Compilação

Esta pasta contém todos os scripts relacionados à compilação do projeto de Semântica Formal.

## Arquivos Principais

- `Makefile`: Script Make principal para compilação
- `compile.bat`: Script unificado para Windows (CMD/PowerShell)
- `compile.sh`: Script unificado para sistemas Unix-like

## Scripts Auxiliares

- `build.bat`: Script auxiliar para Windows CMD
- `build.ps1`: Script auxiliar para PowerShell
- `build.sh`: Script auxiliar para Unix
- `cygwin_build.sh`: Script específico para Cygwin

## Como Funciona

O processo de compilação segue estas etapas:

1. Limpeza de arquivos compilados anteriores
2. Compilação de `Datatypes.ml`
3. Compilação de `Eval.ml`
4. Compilação de `Test.ml`
5. Criação do executável `avaliador`
6. Criação do executável `testes`

## Uso

Os scripts nesta pasta devem ser chamados diretamente pelos usuários.
Para usar o Make, é necessário estar dentro desta pasta:

```bash
# Entre na pasta build antes de usar o make
cd build
make

# Ou use os scripts de compilação diretamente da raiz:
.\build\compile.bat  # Windows
./build/compile.sh   # Unix/Linux
```

## Detecção de Ambiente

Os scripts detectam automaticamente o ambiente de execução:
- Windows CMD
- Windows PowerShell
- Unix-like (Linux, macOS, WSL, Cygwin)

E adaptam os comandos de compilação conforme necessário.

## Nota sobre Geração dos Scripts

Os scripts de compilação foram gerados com assistência de IA (GitHub Copilot) 
para garantir compatibilidade entre diferentes ambientes de desenvolvimento.

## Por que Separar os Scripts de Compilação?

Manter os scripts de compilação em uma pasta separada ajuda a:

1. Manter a raiz do projeto limpa e focada no código-fonte
2. Facilitar a manutenção dos scripts sem interferir na implementação
3. Separar claramente as responsabilidades (código vs. infraestrutura)
4. Melhorar a organização geral do projeto

## Retorno à Raiz do Projeto

Todos os executáveis e artefatos de compilação são gerados na raiz do projeto,
não nesta pasta.

Estes scripts foram criados com auxílio do GitHub Copilot para fornecer
uma experiência de compilação consistente em diferentes ambientes.
