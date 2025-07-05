# Scripts de Compilação

Esta pasta contém os scripts de compilação para o projeto de Semântica Formal - Avaliador Small-Step da Linguagem L2.

## Arquivos Disponíveis

- **`Makefile`**: Script Make para compilação em sistemas Unix/Linux/Mac
- **`build.ps1`**: Script PowerShell para compilação no Windows

## Como Compilar

### Windows (PowerShell)
```powershell
cd build
.\build.ps1
```

### Linux/Mac
```bash
cd build
make all
```

## Executáveis Gerados

Após a compilação bem-sucedida, os seguintes executáveis são criados na **raiz do projeto**:

- **`test`** (Linux/Mac) / **`test.exe`** (Windows): Suite completa de testes
- **`test_for`** (Linux/Mac) / **`test_for.exe`** (Windows): Testes específicos do for loop
- **`teacher_tests`** (Linux/Mac) / **`teacher_tests.exe`** (Windows): Testes do professor

## Processo de Compilação

O processo segue estas etapas:

1. **Configuração do ambiente OCaml** (via OPAM quando disponível)
2. **Limpeza** de arquivos compilados anteriores
3. **Compilação dos módulos**:
   - `Datatypes.ml` → `Datatypes.cmo`
   - `Eval.ml` → `Eval.cmo`
   - `Test.ml` → `Test.cmo`
   - `Test_For.ml` → `Test_For.cmo`
   - `Teacher_tests.ml` → `Teacher_tests.cmo`
4. **Criação dos executáveis**:
   - Linking dos módulos compilados
   - Geração dos executáveis finais
5. **Execução automática dos testes** para validação

## Requisitos

- **OCaml** (versão 4.x ou superior)
- **OPAM** (recomendado para gerenciamento do ambiente)

## Detecção Automática

Os scripts detectam automaticamente:
- Versão do OCaml instalada
- Disponibilidade do OPAM
- Sistema operacional (Windows/Unix)
- Tipo de terminal (CMD/PowerShell)

## Notas

- Todos os executáveis são gerados na **raiz do projeto**, não nesta pasta
- Os scripts incluem validação automática via execução dos testes
- Em caso de erro, a compilação para e exibe mensagens detalhadas
- Os scripts foram otimizados para compatibilidade multiplataforma
