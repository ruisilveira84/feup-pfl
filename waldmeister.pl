% Definição de fatos e regras

% Define os jogadores
players([player1, player2]).

% Define as alturas das árvores
heights([baixo, medio, alto]).

% Define as cores das árvores
colors([verde_claro, verde, verde_escuro]).

% Define as combinações de altura e cor
combinations([(baixo, verde_claro), (baixo, verde), (baixo, verde_escuro),
              (medio, verde_claro), (medio, verde), (medio, verde_escuro),
              (alto, verde_claro), (alto, verde), (alto, verde_escuro)]).

% Inicializa o estado inicial do jogo
initial_state([player1, player2], [(P1Height, P1Color), (P2Height, P2Color)]) :- 
    random_member(P1Height, [baixo, medio, alto]),
    random_member(P1Color, [verde_claro, verde, verde_escuro]),
    random_member(P2Height, [baixo, medio, alto]),
    random_member(P2Color, [verde_claro, verde, verde_escuro]).

% Predicado para mover uma árvore
move([Player, State, Reserve], From, To, NewState) :-
    select((Height, Color), State, TempState),
    select((NewHeight, NewColor), Reserve, TempReserve),
    append(TempState, [(NewHeight, NewColor)], NewBoard),
    append(TempReserve, [(Height, Color)], NewReserve),
    NewState = [Player, NewBoard, NewReserve].

% Predicado para verificar se um jogador venceu
check_winner([_, State, _], Player) :- 
    count_groups(State, Player, Groups),
    max_list(Groups, MaxGroups),
    nth1(Player, Groups, MaxGroups).

% Predicado para contar grupos de acordo com a altura ou cor
count_groups(State, Player, Groups) :-
    heights(Heights),
    colors(Colors),
    combinations(Combinations),
    count_groups_helper(Heights, State, Player, HeightGroups),
    count_groups_helper(Colors, State, Player, ColorGroups),
    append(HeightGroups, ColorGroups, AllGroups),
    count_combinations(Combinations, AllGroups, Groups).

count_groups_helper([], _, _, []).
count_groups_helper([H|T], State, Player, [Count|Rest]) :-
    count_height_or_color(H, State, Player, Count),
    count_groups_helper(T, State, Player, Rest).

count_height_or_color(_, [], _, 0).
count_height_or_color(Target, [(Height, Color)|Rest], Player, Count) :-
    (Player = 1, Height = Target; Player = 2, Color = Target),
    count_height_or_color(Target, Rest, Player, NextCount),
    Count is NextCount + 1;
    count_height_or_color(Target, Rest, Player, Count).

count_combinations([], _, []).
count_combinations([(Height, Color)|Rest], Groups, [Count|Result]) :-
    count_combination(Height, Color, Groups, Count),
    count_combinations(Rest, Groups, Result).

count_combination(Height, Color, Groups, Count) :-
    count_combination_helper(Height, Color, Groups, 0, Count).

count_combination_helper(_, _, [], Count, Count).
count_combination_helper(Height, Color, [(H, C)|Rest], Acc, Count) :-
    ((Height = H; Color = C) -> NextAcc is Acc + 1; NextAcc is Acc),
    count_combination_helper(Height, Color, Rest, NextAcc, Count).

% Exemplo de uso:
% ?- initial_state(State), move(State, (medio, verde_claro), (alto, verde_escuro), NewState).

% Exemplo de implementação do predicado de visualização
display_game(GameState) :-
    % Implementação para exibir o tabuleiro e informações do jogo
    write('Tabuleiro:'), nl,
    print_board(GameState), % Predicado para imprimir o tabuleiro
    nl,
    write('Próximo jogador: '), write(GameState), nl.

% Exemplo de implementação para obter uma lista de jogadas válidas
valid_moves(GameState, ListOfMoves) :-
    % Implementação para gerar uma lista de movimentos válidos
    % Certifique-se de que ListOfMoves contenha uma lista de jogadas válidas.
    % ...

% Exemplo de implementação para verificar o fim do jogo e determinar o vencedor
check_winner(GameState, Winner) :-
    % Implementação para verificar se o jogo terminou e determinar o vencedor
    % O vencedor deve ser unificado com o átomo 'player1' ou 'player2' ou 'draw' caso haja empate.
    % ...

% Exemplo de implementação para avaliar o estado do jogo
value(GameState, Player, Value) :-
    % Implementação para calcular a pontuação de um estado de jogo
    % Certifique-se de definir Value com a pont

% Predicado para exibir o menu principal
main_menu :-
    write('----- Menu Principal -----'), nl,
    write('1. Novo Jogo'), nl,
    write('2. Créditos'), nl,
    write('3. Sair'), nl,
    write('Escolha uma opção: '),
    read_option.

% Predicado para ler a opção do jogador e agir de acordo
read_option :-
    read(Option),
    (
        Option = 1 -> start_new_game
        ;
        Option = 2 -> show_credits, main_menu
        ;
        Option = 3 -> write('Até logo!')
        ;
        write('Opção inválida. Tente novamente.'), nl, main_menu
    ).

% Predicado para iniciar um novo jogo (como anteriormente)
start_new_game :-
    write('A iniciar um novo jogo...'), nl,
    play,
    main_menu.

% Predicado para exibir os créditos
show_credits :-
    write('----- Créditos -----'), nl,
    write('André dos Santos Faria Relva (up202108695)'), nl,
    write('Rui Pedro Almeida da Silveira (up202108878)'), nl,
    write('FEUP'), nl,
    write('0. Voltar ao Menu Principal'), nl,
    write('Escolha uma opção: '),
    read_option.
