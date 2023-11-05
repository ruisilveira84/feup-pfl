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
initial_state([player1, player2], [Inventory1, Inventory2]) :- 
    combinations(AllCombinations),
    Inventory1 = AllCombinations,
    Inventory2 = AllCombinations.

% Predicado para mover uma árvore
move([Player, State, [PlayerInventory, OpponentInventory]], From, To, NewState) :-
    select((Height, Color), PlayerInventory, TempPlayerInventory),
    select((NewHeight, NewColor), OpponentInventory, TempOpponentInventory),
    append(State, [(NewHeight, NewColor)], NewBoard),
    NewPlayerInventory = TempPlayerInventory,
    NewOpponentInventory = TempOpponentInventory,
    NewState = [Player, NewBoard, [NewPlayerInventory, NewOpponentInventory]].

% Predicado para verificar se um jogador venceu
check_winner([_, State, _], Winner) :-
    count_groups(State, 1, Count1),
    count_groups(State, 2, Count2),
    (Count1 > Count2 -> Winner = 1 ; Count2 > Count1 -> Winner = 2 ; Winner = 0).

% Predicado para verificar o fim do jogo e determinar o vencedor
game_over([_, State, _], Winner) :-
    count_groups(State, 1, Player1Groups),
    count_groups(State, 2, Player2Groups),
    (Player1Groups > Player2Groups -> Winner = player1 ;
     Player1Groups < Player2Groups -> Winner = player2 ;
     Winner = 'Draw').

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
% ?- initial_state(State), move(State, (medium, yellow_green), (tall, dark_green), NewState).

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
waldmeister :-
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
        Option = 1 -> start_game
        ;
        Option = 2 -> show_credits, waldmeister
        ;
        Option = 3 -> nl, write('See you soon!'), nl, wait_seconds(3), halt % Adicionado o halt/0 para encerrar o programa
        ;
        write('Invalid option.'), nl, waldmeister
    ).

wait_seconds(0).
wait_seconds(N) :- N > 0, N1 is N - 1, wait_seconds(N1).

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
    initialize_players,
    print_board([_,[],[]]), % Adicionando esta linha para imprimir o tabuleiro vazio
    play.

% Predicado para iniciar o jogo
start_game :-
    initialize_players,
    set_current_player(player1),
    display_game([_, [], []]), % Mostra o tabuleiro vazio no início
    nl,
    make_first_move.

make_first_move :-
    repeat,
    get_current_player(Player),
    nl, write('Player '), write(Player), write(', enter your move (e.g., (row, column).): '),
    read(From),
    initial_state(_, [(P1Height, P1Color), (P2Height, P2Color)]),
    (valid_first_move(Player, From, [(P1Height, P1Color), (P2Height, P2Color)]) ->
        nl, write('Now choose the type of tree (e.g., S(YG), M(LG), T(DG)).: '),
        read(Tree),
        % Atualiza o estado do jogo
        move([Player, [], [(P1Height, P1Color), (P2Height, P2Color)]], (From, 8), (From, Tree), NewGameState),
        display_game(NewGameState),
        set_current_player(player2), % Alterna para o próximo jogador
        ! % Sai do loop
    ;
        write('Invalid move! Please try again.'), nl,
        fail % Continua a pedir um movimento válido
    ).

valid_first_move(Player, From, [(P1Height, P1Color), (P2Height, P2Color)]) :-
    number(From),
    (Player = player1, From >= 1, From =< 15) ;
    (Player = player2, From >= 1, From =< 15).

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
    write('Current Player: '), write(Player).

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
    read(From),
    read(To),
    (valid_move_format(From, To, Move, ValidMoves) ->
        true
    ;
        write('Invalid move! Please try again.'), nl,
        fail
    ).

valid_move_format(From, To, (From,To), ValidMoves) :-
    number(From), number(To),
    member((From, To), ValidMoves).

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

% Predicado para imprimir a legenda
print_legend :-
    nl,
    write('| Informations: T(__) Tall, M(__) Medium, S(__) Short    |'), nl,
    write('| _(YG) Yellow Green, _(LG) Leaf Green, _(DG) Dark Green |'), nl.

% Predicado para imprimir o estado do tabuleiro
print_board([_, _, _]) :-
    draw_board. % Utiliza o novo predicado draw_board para imprimir o tabuleiro

% Definir os predicados para desenhar o tabuleiro com as árvores
assertz(trees(' ', ' ', r01_1)).
assertz(trees(' ', ' ', r02_1)).
assertz(trees(' ', ' ', r02_2)).
assertz(trees(' ', ' ', r03_1)).
assertz(trees(' ', ' ', r03_2)).
assertz(trees(' ', ' ', r03_3)).
assertz(trees(' ', ' ', r04_1)).
assertz(trees(' ', ' ', r04_2)).
assertz(trees(' ', ' ', r04_3)).
assertz(trees(' ', ' ', r04_4)).
assertz(trees(' ', ' ', r05_1)).
assertz(trees(' ', ' ', r05_2)).
assertz(trees(' ', ' ', r05_3)).
assertz(trees(' ', ' ', r05_4)).
assertz(trees(' ', ' ', r05_5)).
assertz(trees(' ', ' ', r06_1)).
assertz(trees(' ', ' ', r06_2)).
assertz(trees(' ', ' ', r06_3)).
assertz(trees(' ', ' ', r06_4)).
assertz(trees(' ', ' ', r06_5)).
assertz(trees(' ', ' ', r06_6)).
assertz(trees(' ', ' ', r07_1)).
assertz(trees(' ', ' ', r07_2)).
assertz(trees(' ', ' ', r07_3)).
assertz(trees(' ', ' ', r07_4)).
assertz(trees(' ', ' ', r07_5)).
assertz(trees(' ', ' ', r07_6)).
assertz(trees(' ', ' ', r07_7)).
assertz(trees(' ', ' ', r08_1)).
assertz(trees(' ', ' ', r08_2)).
assertz(trees(' ', ' ', r08_3)).
assertz(trees(' ', ' ', r08_4)).
assertz(trees(' ', ' ', r08_5)).
assertz(trees(' ', ' ', r08_6)).
assertz(trees(' ', ' ', r08_7)).
assertz(trees(' ', ' ', r08_8)).
assertz(trees(' ', ' ', r09_1)).
assertz(trees(' ', ' ', r09_2)).
assertz(trees(' ', ' ', r09_3)).
assertz(trees(' ', ' ', r09_4)).
assertz(trees(' ', ' ', r09_5)).
assertz(trees(' ', ' ', r09_6)).
assertz(trees(' ', ' ', r09_7)).
assertz(trees(' ', ' ', r10_1)).
assertz(trees(' ', ' ', r10_2)).
assertz(trees(' ', ' ', r10_3)).
assertz(trees(' ', ' ', r10_4)).
assertz(trees(' ', ' ', r10_5)).
assertz(trees(' ', ' ', r10_6)).
assertz(trees(' ', ' ', r11_1)).
assertz(trees(' ', ' ', r11_2)).
assertz(trees(' ', ' ', r11_3)).
assertz(trees(' ', ' ', r11_4)).
assertz(trees(' ', ' ', r11_5)).
assertz(trees(' ', ' ', r12_1)).
assertz(trees(' ', ' ', r12_2)).
assertz(trees(' ', ' ', r12_3)).
assertz(trees(' ', ' ', r12_4)).
assertz(trees(' ', ' ', r13_1)).
assertz(trees(' ', ' ', r13_2)).
assertz(trees(' ', ' ', r13_3)).
assertz(trees(' ', ' ', r14_1)).
assertz(trees(' ', ' ', r14_2)).
assertz(trees(' ', ' ', r15_1)).

draw_line([]) :- nl, !.
draw_line([H|T]) :- trees(C, H, F), !,
                    write('('),
                    write(C),
                    write(' '),
                    write(H),
                    write(')'),
                    draw_line(T). 

draw_line([H|T]) :- write(H), draw_line(T).

draw_board :-   nl,
                draw_line(['                            | ', r01_1, ' |']),
                draw_line(['                        | ', r02_1, ' | ',r02_2, ' |']),
                draw_line(['                    | ', r03_1, ' | ',r03_2, ' | ',r03_3, ' |']),
                draw_line(['                | ', r04_1, ' | ', r04_2, ' | ', r04_3, ' | ', r04_4, ' |']),
                draw_line(['            | ', r05_1, ' | ', r05_2, ' | ', r05_3, ' | ', r05_4, ' | ', r05_5, ' |']),
                draw_line(['        | ', r06_1, ' | ', r06_2, ' | ', r06_3, ' | ', r06_4, ' | ', r06_5, ' | ', r06_6, ' |']),
                draw_line(['    | ', r07_1, ' | ', r07_2, ' | ', r07_3, ' | ', r07_4, ' | ', r07_5, ' | ', r07_6, ' | ', r70_7, ' |']),
                draw_line(['| ', r08_1, ' | ', r08_2, ' | ', r08_3, ' | ', r08_4, ' | ', r08_5, ' | ', r08_6, ' | ', r08_7, ' | ', r08_8, ' |']),
                draw_line(['    | ', r09_1, ' | ', r09_2, ' | ', r09_3, ' | ', r09_4, ' | ', r09_5, ' | ', r09_6, ' | ', r09_7, ' |']),
                draw_line(['        | ', r10_1, ' | ', r10_2, ' | ', r10_3, ' | ', r10_4, ' | ', r10_5, ' | ', r10_6, ' |']),
                draw_line(['            | ', r11_1, ' | ', r11_2, ' | ', r11_3, ' | ', r11_4, ' | ', r11_5, ' |']),
                draw_line(['                | ', r12_1, ' | ', r12_2, ' | ', r12_3, ' | ', r12_4, ' |']),
                draw_line(['                    | ', r13_1, ' | ', r13_2, ' | ', r13_3, ' |']),
                draw_line(['                        | ', r14_1, ' | ', r14_2, ' |']),
                draw_line(['                            | ', r15_1, ' |']).

% Exemplo de uso:
% ?- waldmeister.

