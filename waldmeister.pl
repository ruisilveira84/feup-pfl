% Define os jogadores
players([player1, player2]).

% Define as alturas das árvores
heights([short, medium, tall]).

% Define as cores das árvores
colors([yellow_green, leaf_green, dark_green]).

% Define as combinações de altura e cor
combinations([(short, yellow_green), (short, leaf_green), (short, dark_green),
              (medium, yellow_green), (medium, leaf_green), (medium, dark_green),
              (tall, yellow_green), (tall, leaf_green), (tall, dark_green)]).

% Inicializa o estado inicial do jogo
initial_state([player1, player2], [(P1Height, P1Color), (P2Height, P2Color)]) :- 
    random_member(P1Height, [short, medium, tall]),
    random_member(P1Color, [yellow_green, leaf_green, dark_green]),
    random_member(P2Height, [short, medium, tall]),
    random_member(P2Color, [yellow_green, leaf_green, dark_green]).

% Predicado para mover uma árvore
move([Player, State, Reserve], From, To, NewState) :-
    select((Height, Color), State, TempState),
    select((NewHeight, NewColor), Reserve, TempReserve),
    append(TempState, [(NewHeight, NewColor)], NewBoard),
    append(TempReserve, [(Height, Color)], NewReserve),
    NewState = [Player, NewBoard, NewReserve].

% Predicado para imprimir a altura e cor de uma árvore
write_height_color(short, yellow_green, _) :- write('_(YG)').
write_height_color(short, leaf_green, _) :- write('_(LG)').
write_height_color(short, dark_green, _) :- write('_(DG)').
write_height_color(medium, yellow_green, _) :- write('M(YG)').
write_height_color(medium, leaf_green, _) :- write('M(LG)').
write_height_color(medium, dark_green, _) :- write('M(DG)').
write_height_color(tall, yellow_green, _) :- write('T(YG)').
write_height_color(tall, leaf_green, _) :- write('T(LG)').
write_height_color(tall, dark_green, _) :- write('T(DG)').

% Predicado para verificar se um jogador venceu
check_winner([_, State, _], Winner) :-
    count_groups(State, 1, Count1),
    count_groups(State, 2, Count2),
    (Count1 > Count2 -> Winner = 1 ; Count2 > Count1 -> Winner = 2 ; Winner = 0).

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

% Predicado para obter uma lista de jogadas válidas
valid_moves([Player, State, Reserve], ListOfMoves) :-
    findall((From, To), valid_move(Player, State, Reserve, From, To), ListOfMoves).

% Predicado auxiliar para determinar se um movimento é válido
valid_move(Player, State, Reserve, From, To) :-
    member((From, Color), State),               % Pega uma árvore do tabuleiro
    member((To, _), Reserve),                   % Pega um espaço da reserva
    move([Player, State, Reserve], From, To, _). % Verifica se o movimento é válido

% Predicado para avaliar o estado do jogo
value([_, State, _], Player, Value) :-
    count_groups(State, Player, PlayerGroups),
    count_groups(State, Player, OpponentGroups),
    Value is PlayerGroups - OpponentGroups.

% Exemplo de uso:
% ?- initial_state(State), move(State, (medio, verde_claro), (alto, verde_escuro), NewState).

% Exemplo de implementação do predicado de visualização
display_game(GameState) :-
    print_board(GameState), % Predicado para imprimir o tabuleiro
    print_legend, % Predicado para imprimir a legenda
    nl,
    show_current_player.

% Predicado para verificar o fim do jogo e determinar o vencedor
check_winner(GameState, Winner) :-
    valid_moves(GameState, Moves),
    length(Moves, NumMoves),
    (NumMoves = 0 -> 
        get_current_player(Player), 
        (Player = player1 -> Opponent = player2 ; Opponent = player1),
        value(GameState, Player, PlayerValue),
        value(GameState, Opponent, OpponentValue),
        (PlayerValue > OpponentValue -> Winner = Player ;
         PlayerValue < OpponentValue -> Winner = Opponent ;
         Winner = 'Draw')
    ;
    Winner = 'Game still in progress').

% Predicado para avaliar o estado do jogo
value(GameState, Player, Value) :-
    count_groups(GameState, Player, PlayerGroups),
    count_groups(GameState, Player, OpponentGroups),
    Value is PlayerGroups - OpponentGroups.

% Predicado para exibir o menu principal
main_menu :-
    nl,
    write('----- WaldMeister -----'), nl,
    write('1. New Game'), nl,
    write('2. Credits'), nl,
    write('3. Exit'), nl,
    write('> '),
    read_option.

% Predicado para ler a opção do jogador e agir de acordo
read_option :-
    read(Option),
    (
        Option = 1 -> start_new_game
        ;
        Option = 2 -> show_credits, main_menu
        ;
        Option = 3 -> nl, write('See you soon!'), nl
        ;
        write('Invalid option.'), nl, main_menu
    ).

% Predicado para mostrar os créditos
show_credits :-
    nl,
    write('----- Credits -----'), nl,
    write('This game was created by:'), nl,
    write('Andre Relva (up202108695)'), nl,
    write('Rui Silveira (up202108878)'), nl,
    write('From FEUP'), nl,
    write('Have Fun!'), nl.

% Predicado para iniciar um novo jogo (como anteriormente)
start_new_game :-
    write('Loading...'), nl,
    initialize_players,
    play.

% Predicado para iniciar o jogo
start_game :-
    initialize_players,
    set_current_player(player1),
    main_menu.

% Inicializa os jogadores
initialize_players :-
    assertz(player('player1')),
    assertz(player('player2')).

% Define o jogador atual
set_current_player(Player) :-
    retractall(current_player(_)),
    assertz(current_player(Player)).

% Obtém o jogador atual
get_current_player(Player) :-
    current_player(Player).

% Mostra o jogador atual
show_current_player :- 
    get_current_player(Player), 
    write('Current Player: '), write(Player), nl.

% Predicado para fazer um movimento no jogo
make_move(GameState, NewGameState) :-
    display_game(GameState), % Mostra o estado atual do jogo

    % Obtém a lista de movimentos válidos para o jogador atual
    get_current_player(Player),
    valid_moves(GameState, ValidMoves),

    % Exibe os movimentos válidos disponíveis para o jogador
    write('Valid moves: '), write(ValidMoves), nl,

    % Obtém o movimento do jogador
    get_player_move(ValidMoves, Move),

    % Executa o movimento e atualiza o estado do jogo
    move(GameState, Move, NewGameState).

% Predicado para obter o movimento do jogador
get_player_move(ValidMoves, Move) :-
    repeat,
    nl, write('Enter your move (e.g., (from, to).): '),
    read(Move),
    member(Move, ValidMoves), !.

% Predicado para coordenar o jogo
play :-
    repeat,
    get_current_player(Player),
    make_move(GameState, NewGameState),
    check_winner(NewGameState, Winner),
    (
        Winner \= 'Game still in progress' -> 
            display_game(NewGameState),
            write('Winner: '), write(Winner), nl
        ;
            set_current_player(Player),
            switch_player, % Alterna para o próximo jogador
            fail
    ).

% Predicado para alternar o jogador atual
switch_player :-
    get_current_player(CurrentPlayer),
    players(Players),
    nth1(Index, Players, CurrentPlayer),
    NextIndex is Index mod 2 + 1,
    nth1(NextIndex, Players, NextPlayer),
    set_current_player(NextPlayer).

% Predicado para imprimir o estado do tabuleiro
print_board([_, State, _]) :-
    print_rows(State).

% Predicado auxiliar para imprimir as linhas do tabuleiro
print_rows([]).
print_rows([Row|Rest]) :-
    print_row(Row),
    print_rows(Rest).

% Predicado auxiliar para imprimir uma linha do tabuleiro
print_row([]) :- 
    write('|'),
    nl.
print_row([(Height, Color)|Rest]) :-
    write('| '), write_height_color(Height, Color),
    print_row(Rest).

% Predicado para imprimir a legenda
print_legend :-
    nl,
    write('| Informations: T(__) Tall, M(__) Medium, S(__) Short    |'), nl,
    write('| _(YG) Yellow Green, _(LG) Leaf Green, _(DG) Dark Green |'), nl.
