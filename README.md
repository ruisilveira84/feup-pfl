# WaldMeister Gold Edition

## Identificação do trabalho e do grupo

Grupo Wald Meister_1

- André dos Santos Faria Relva (202108695) - 50%
- Rui Pedro Almeida da Silveira (202108878) - 50%

## Jogo escolhido

WaldMeister

## Instalação e Execução

### Instalação

Para instalar o jogo, basta consultar o arquivo waldmeister.pl na pasta do projeto. Todas as dependências necessárias serão carregadas automaticamente.

### Execução

O predicado `play/0` inicia a aplicação.

## Descrição do jogo

O WaldMeister é um jogo de tabuleiro para 2 jogadores que desejam moldar uma floresta de acordo com seus objetivos. Cada jogador começa com 27 árvores, com diferentes alturas e cores. Os jogadores movem e colocam, à vez, as árvores no tabuleiro, com um jogador tentando criar grupos de acordo com a altura e o outro tentando criar grupos de acordo com a cor.

O objetivo é criar grupos de árvores de acordo com as regras específicas do jogo, e o jogador com a soma mais alta de grupos vence.
rui@PCofRUI:~/Desktop$ git push -u origin main

 estado do jogo

O estado do jogo é representado por um par (Tabuleiro-Jogador), onde o Tabuleiro é uma lista de listas que representa o tabuleiro de jogo e o Jogador indica qual jogador está no turno.

### Visualização do estado de jogo

O predicado `display_game(+GameState)` aceita um estado de jogo e mostra na consola o estado atual do tabuleiro.

### Execução de Jogadas

O predicado `move(+GameState, +From, +To, -NewGameState)` permite aos jogadores mover e colocar árvores no tabuleiro de acordo com as regras do jogo.

### Final do Jogo

O predicado `check_winner(+GameState, -Winner)` determina o vencedor do jogo em um dado estado.

### Lista de Jogadas Válidas

O predicado `valid_moves(+GameState, -ListOfMoves)` retorna a lista de jogadas válidas para avançar em um dado estado de jogo.

### Avaliação do Estado do Jogo

Avaliar o estado do jogo é crucial para a tomada de decisões dos jogadores. O predicado `value(+GameState, +Player, -Value)` calcula uma pontuação baseada nas jogadas disponíveis para cada jogador.

### Jogada do Computador

O computador escolhe sua jogada com base em uma heurística que busca a melhor jogada no momento, maximizando a pontuação do jogador.

## Conclusões

O projeto do WaldMeister foi concluído com sucesso, atingindo todas as metas estabelecidas. O código está bem estruturado, modular e eficiente.

## Bibliografia

- [Documentação da UC](https://sigarra.up.pt/feup/pt/ucurr_geral.ficha_uc_view?pv_ocorrencia_id=520329)
- [SWI-Prolog Documentation](https://www.swi-prolog.org/)
- [Regras do Jogo WaldMeister](https://boardgamegeek.com/boardgame/371135/waldmeister)
