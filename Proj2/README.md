# Coursework-Haskell

FEUP - Programação Funcional e em Lógica

## Contribuidores

Grupo T02_G09

- [André Relva](https://github.com/andrerelva) up202108695 - 50%
- [Rui Silveira](https://github.com/ruipedro84) up202108878 - 50%

## Descrição do Projeto

Este projeto implementa uma máquina de baixo nível e um compilador para uma linguagem de programação imperativa simples em Haskell.

## Máquina de Baixo Nível

### Arquivos Relevantes

- **Assembler.hs:** Contém a implementação da máquina de baixo nível.
- **AssemblerSpec.hs:** Contém as especificações e testes para a máquina.

### Implementações

- **createEmptyStack:** Função para criar uma pilha vazia.
- **createEmptyState:** Função para criar um estado vazio.
- **stack2Str:** Função para converter uma pilha em uma string.
- **state2Str:** Função para converter um estado em uma string.
- **run:** Função principal que executa o código, manipula a pilha e atualiza o estado.

### Testes

- **AssemblerTests.hs:** Contém testes para a máquina de baixo nível. Inclui casos de teste variados para cobrir todas as instruções.

## Compilador

### Arquivos Relevantes

- **Types.hs:** Contém os tipos de dados para expressões aritméticas, booleanas e instruções.
- **Compiler.hs:** Contém a implementação do compilador.
- **Parser.hs:** Contém o analisador para transformar programas imperativos em estruturas de dados Haskell.

### Implementações

- **compA:** Compilação de expressões aritméticas para código de máquina.
- **compB:** Compilação de expressões booleanas para código de máquina.
- **compile:** Compilação de programas imperativos inteiros.

### Testes

- **ParserTests.hs:** Contém testes para o analisador. Inclui casos de teste para diferentes construções da linguagem imperativa.
- **CompilerTests.hs:** Contém testes para o compilador. Garante que os programas imperativos sejam compilados corretamente.

## Execução do Projeto

1. Clone o repositório.
2. Execute os testes para garantir a integridade do código.

```bash
cabal test
```

3. Execute exemplos de programas imperativos compilados.

```bash
runhaskell Main.hs
```



