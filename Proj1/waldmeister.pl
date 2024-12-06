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





% Predicado para verificar se todos os espaços estão preenchidos
all_spaces_filled([]).
all_spaces_filled([H|T]) :-
    \+ clause(trees(' ', ' ', H), true),
    all_spaces_filled(T).

% Predicado para verificar o fim do jogo e determinar o vencedor
game_over(Board, Winner) :-
    all_spaces_filled(Board),
    
    


    Winner = player1. % Exemplo de atribuição do vencedor.
    write('Game over! Winner: '), write(Winner), nl, nl, nl,
    play. % Volta ao menu principal.

% Exemplo de chamada
% game_over(Board, Winner).




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

    switch_current_player,
    show_current_player, nl.

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
play :-
    nl,
    write('----- WaldMeister -----'), nl,
    write('1. New Game'), nl,
    write('2. Instructions'), nl,
    write('3. Credits'), nl,
    write('4. Exit'), nl,
    write('> '),
    read_option.

% Predicado para ler a opção do jogador e agir de acordo
read_option :-
    read(Option),
    (
        Option = 1 -> game_type
        ;
        Option = 2 -> show_instructions, play
        ;
        Option = 3 -> show_credits, play
        ;
        Option = 4 -> nl, write('See you soon!'), nl, wait_seconds(1000000), halt % Adicionado o halt/0 para encerrar o programa
        ;
        write('Invalid option.'), nl, play
    ).

wait_seconds(0).
wait_seconds(N) :- N > 0, N1 is N - 1, wait_seconds(N1).

% Predicado para mostrar as intruções
show_instructions :-
    nl,
    write('----- Instructions -----'), nl,
    write('Objective: create groups of trees with similar characteristics, such as height and color'), nl,
    write('Winner: the player with the highest number in their group is the winner!'), nl,
    write('Are you ready!'), nl.

% Predicado para mostrar os créditos
show_credits :-
    nl,
    write('----- Credits -----'), nl,
    write('This game was created by:'), nl,
    write('Andre Relva (up202108695)'), nl,
    write('Rui Silveira (up202108878)'), nl,
    write('From FEUP'), nl,
    write('Have Fun!'), nl.

% Predicado para mostrar os créditos
game_type :-
    write('----- Game Type -----'), nl,
    write('1. Player vs Player'), nl,
    write('2. Player vs Computer'), nl,
    write('> '),
    read_option_game_type.

% Predicado para ler a opção do jogador e agir de acordo
read_option_game_type :-
    read(Option),
    (
        Option = 1 -> set_initial, start_game
        ;
        Option = 2 -> play
        ;
        write('Invalid option.'), nl, game_type
    ).





% Predicado para iniciar o jogo
start_game :-
    set_current_player(player2),
    display_game([_, [], []]), % Mostra o tabuleiro vazio no início
    nl,
    make_first_move.

make_first_move :-
    write('Enter your move (e.g. r03_1): '),
    read(From),
    valid_first_move(From).

valid_first_move(From) :-
    (   clause(trees(' ', ' ', From), true)
    -> nl, write('Now choose the size of new tree (e.g. s/m/t): '),
        read(Size),        
        valid_size(Size, From)
    ; write('Invalid board space'), nl, nl, make_first_move
    ).

valid_size(Size, From) :-
    (   clause(sizes(Size), true)
    -> nl, write('Now choose the color of new tree (e.g. yg/lg/dg): '),
        read(Color),        
        valid_color(Color, Size, From)
    ; write('Invalid size'), nl, valid_first_move(From)
    ).

valid_color(Color, Size, From) :-
    (   clause(color(Color), true)
    -> nl, 
        update_tree_database_first(From, Color, Size), % Atualiza o banco de dados com a nova árvore
        display_game(NewGameState),
        choose_existing_piece
    ; write('Invalid color'), nl, valid_first_move(From)
    ).

% Predicado para atualizar a base de dados com a primeira árvore
update_tree_database_first(From, Color, Size) :-
    (   retract(trees(OldColor, OldSize, From)) % Remove a árvore anterior de 'From'
    -> assertz(last_tree(OldColor, OldSize)) % Adiciona a árvore anterior em last_tree/2
    ;   assertz(last_tree(' ', ' ')) % Se não houver árvore anterior, mantém ' ' em last_tree/2
    ),
    assertz(trees(Color, Size, From)). % Adiciona a nova árvore à base de dados






valid_size_2(Size, From) :-
    (   clause(sizes(Size), true)
    -> nl, write('Now choose the color of new tree (e.g. yg/lg/dg): '),
        read(Color),        
        valid_color_2(Color, Size, From)
    ; write('Invalid size'), nl, choose_existing_piece
    ).

valid_color_2(Color, Size, From) :-
    (   clause(color(Color), true)
    -> nl, 
        update_tree_database(From, Color, Size), % Atualiza o banco de dados com a nova árvore
        display_game(NewGameState),
        choose_existing_piece
    ; write('Invalid color'), nl, choose_existing_piece
    ).






% Predicado para atualizar a base de dados com a nova árvore
update_tree_database(From, Color, Size) :-
    (   retract(trees(OldColor, OldSize, From)) % Remove a árvore anterior de 'From'
    -> assertz(last_tree(OldColor, OldSize, From)) % Adiciona a árvore anterior em last_tree/2
    ;   assertz(last_tree(' ', ' ',' ')) % Se não houver árvore anterior, mantém ' ' em last_tree/2
    ),
    assertz(trees(Color, Size, From)), % Adiciona a nova árvore à base de dados
    aux_input_move_last_tree.



aux_input_move_last_tree :-
    write('Enter the move of the present tree (e.g. r03_1): '),
    read(To),
    move_last_tree(To).

% Predicado para mover a outra árvore
move_last_tree(To) :-
    (   clause(trees(' ', ' ', To), true)
    ->
        valid_last_tree_move(To), % Verifica se o movimento é válido (apenas em colunas e diagonais)
        retract(last_tree(_, _, _)), % Remove a árvore de last_tree/2
        assertz(trees(Color, Size, To)) % Adiciona a árvore na nova posição
    ; write('Invalid board space'), nl, nl, aux_input_move_last_tree
    ).



% Predicado para verificar se o movimento é válido
valid_last_tree_move(To) :-
    last_tree(Color, Size, From), % Obtém a árvore de last_tree
    no_trees_in_the_way(From, To).

% Predicado para verificar se não há árvores no caminho
no_trees_in_the_way(From, To) :-
    diagonal(DiagList), % Obtemos a lista da diagonal
    member(DiagList, Diagonal), % Pegamos uma lista dentro da diagonal
    list_func(DiagList, From, To). % Verificamos se não há árvores no caminho
    /*(
        same_diagonal(From, To) % Verifica se From e To estão na mesma diagonal
    ->
        diagonal(DiagList), % Obtemos a lista da diagonal
        member(DiagList, Diagonal), % Pegamos uma lista dentro da diagonal
        list_func(DiagList, From, To) % Verificamos se não há árvores no caminho
    ;   
        same_column(From, To) % Se não estiverem na mesma diagonal, verificamos se estão na mesma coluna
    ->
        column(Column),
        list_func(Column, From, To) % Verificamos se não há árvores no caminho
    ;   % Caso contrário, a movimentação não é válida
        write('Invalid move. It must be in the same column or diagonal.'), nl,
        aux_input_move_last_tree
    ).*/

% Função auxiliar para verificar se não há árvores no caminho
list_func(List, From, To) :-
    read_list(List, From, To).

read_list([H|T], From, To) :-
    (   
        H = From ->
        check_list(T, To)
    ; 
        H = To ->
        check_list(T, From)
    ; 
        read_list(T, From, To)
    ).

check_list([H|T], K) :-
    (   
        clause(trees(' ', ' ', H), true)
    ->
        (   
            H = K
        ->
            write('work')
        ; 
            check_list(T, K) 
        )
    ; 
        write('Invalid move, tree in the way'), nl
    ).
check_list([], _).






same_column(From, To) :-
    column(Column),
    member(From, Column),
    member(To, Column),
    From \= To. % Verifica se From e To são diferentes para não serem o mesmo elemento


same_diagonal(From, To) :-
    diagonal(Diagonal),
    member(DiagList, Diagonal),
    member(From, DiagList),
    member(To, DiagList),
    From \= To. % Verifica se From e To são diferentes para não serem o mesmo elemento




choose_existing_piece :-
    nl, write('Choose an existing tree (e.g. r03_1): '),
    read(From),
    valid_move(From).

valid_move(From) :-
    (   
        clause(trees(yg, _, From), true)
    -> 
        nl, write('Now choose the size of new tree (e.g. s/m/t): '),
        read(Size),        
        valid_size_2(Size, From)
    ; 
        clause(trees(lg, _, From), true)
    -> 
        nl, write('Now choose the size of new tree (e.g. s/m/t): '),
        read(Size),        
        valid_size_2(Size, From)
    ; 
        clause(trees(dg, _, From), true)
    -> 
        nl, write('Now choose the size of new tree (e.g. s/m/t): '),
        read(Size),        
        valid_size_2(Size, From)
    ; 
        write('Invalid board space'), nl, choose_existing_piece
    ).





% Predicado para alternar o jogador atual
switch_current_player :-
    get_current_player(CurrentPlayer),
    (CurrentPlayer = player1 -> NewPlayer = player2 ; NewPlayer = player1),
    set_current_player(NewPlayer).

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

    % Exibe os movimentos válidos disponíveis para o jogador
    write('Valid moves: '), write(ValidMoves), nl,

    % Obtém o movimento do jogador
    get_player_move(ValidMoves, Move),

    % Executa o movimento e atualiza o estado do jogo
    move(GameState, Move, NewGameState).



% Predicado para imprimir a legenda
print_legend :-
    nl,
    write('| Informations: t Tall, m Medium, s Short       |'), nl,
    write('| yg Yellow Green, lg Leaf Green, dg Dark Green |'), nl.

% Predicado para imprimir o estado do tabuleiro
print_board([_, _, _]) :-
    draw_board. % Utiliza o novo predicado draw_board para imprimir o tabuleiro

% Definir os predicados para desenhar o tabuleiro com as árvores
set_initial :-
    assertz(trees(' ', ' ', r01_1)),
    assertz(trees(' ', ' ', r02_1)),
    assertz(trees(' ', ' ', r02_2)),
    assertz(trees(' ', ' ', r03_1)),
    assertz(trees(' ', ' ', r03_2)),
    assertz(trees(' ', ' ', r03_3)),
    assertz(trees(' ', ' ', r04_1)),
    assertz(trees(' ', ' ', r04_2)),
    assertz(trees(' ', ' ', r04_3)),
    assertz(trees(' ', ' ', r04_4)),
    assertz(trees(' ', ' ', r05_1)),
    assertz(trees(' ', ' ', r05_2)),
    assertz(trees(' ', ' ', r05_3)),
    assertz(trees(' ', ' ', r05_4)),
    assertz(trees(' ', ' ', r05_5)),
    assertz(trees(' ', ' ', r06_1)),
    assertz(trees(' ', ' ', r06_2)),
    assertz(trees(' ', ' ', r06_3)),
    assertz(trees(' ', ' ', r06_4)),
    assertz(trees(' ', ' ', r06_5)),
    assertz(trees(' ', ' ', r06_6)),
    assertz(trees(' ', ' ', r07_1)),
    assertz(trees(' ', ' ', r07_2)),
    assertz(trees(' ', ' ', r07_3)),
    assertz(trees(' ', ' ', r07_4)),
    assertz(trees(' ', ' ', r07_5)),
    assertz(trees(' ', ' ', r07_6)),
    assertz(trees(' ', ' ', r07_7)),
    assertz(trees(' ', ' ', r08_1)),
    assertz(trees(' ', ' ', r08_2)),
    assertz(trees(' ', ' ', r08_3)),
    assertz(trees(' ', ' ', r08_4)),
    assertz(trees(' ', ' ', r08_5)),
    assertz(trees(' ', ' ', r08_6)),
    assertz(trees(' ', ' ', r08_7)),
    assertz(trees(' ', ' ', r08_8)),
    assertz(trees(' ', ' ', r09_1)),
    assertz(trees(' ', ' ', r09_2)),
    assertz(trees(' ', ' ', r09_3)),
    assertz(trees(' ', ' ', r09_4)),
    assertz(trees(' ', ' ', r09_5)),
    assertz(trees(' ', ' ', r09_6)),
    assertz(trees(' ', ' ', r09_7)),
    assertz(trees(' ', ' ', r10_1)),
    assertz(trees(' ', ' ', r10_2)),
    assertz(trees(' ', ' ', r10_3)),
    assertz(trees(' ', ' ', r10_4)),
    assertz(trees(' ', ' ', r10_5)),
    assertz(trees(' ', ' ', r10_6)),
    assertz(trees(' ', ' ', r11_1)),
    assertz(trees(' ', ' ', r11_2)),
    assertz(trees(' ', ' ', r11_3)),
    assertz(trees(' ', ' ', r11_4)),
    assertz(trees(' ', ' ', r11_5)),
    assertz(trees(' ', ' ', r12_1)),
    assertz(trees(' ', ' ', r12_2)),
    assertz(trees(' ', ' ', r12_3)),
    assertz(trees(' ', ' ', r12_4)),
    assertz(trees(' ', ' ', r13_1)),
    assertz(trees(' ', ' ', r13_2)),
    assertz(trees(' ', ' ', r13_3)),
    assertz(trees(' ', ' ', r14_1)),
    assertz(trees(' ', ' ', r14_2)),
    assertz(trees(' ', ' ', r15_1)),
    assertz(combination(s_yg)),
    assertz(combination(m_yg)),
    assertz(combination(t_yg)),
    assertz(combination(s_lg)),
    assertz(combination(m_lg)),
    assertz(combination(t_lg)),
    assertz(combination(s_dg)),
    assertz(combination(m_dg)),
    assertz(combination(t_dg)),
    assertz(sizes(s)),
    assertz(sizes(m)),
    assertz(sizes(t)),
    assertz(color(yg)),
    assertz(color(lg)),
    assertz(color(dg)),
    assertz(last_tree(' ',' ',' ')),
    assertz(player('player1')),
    assertz(player('player2')),
    assertz(diagonal([r01_1, r02_1, r03_1, r04_1, r05_1, r06_1, r07_1, r08_1])),
    assertz(diagonal([r02_2, r03_2, r04_2, r05_2, r06_2, r07_2, r08_2, r09_1])),
    assertz(diagonal([r03_3, r04_3, r05_3, r06_3, r07_3, r08_3, r09_2, r10_1])),
    assertz(diagonal([r04_4, r05_4, r06_4, r07_4, r08_4, r09_3, r10_2, r11_1])),
    assertz(diagonal([r05_5, r06_5, r07_5, r08_5, r09_4, r10_3, r11_2, r12_1])),
    assertz(diagonal([r06_6, r07_6, r08_6, r09_5, r10_4, r11_3, r12_2, r13_1])),
    assertz(diagonal([r07_7, r08_7, r09_6, r10_5, r11_4, r12_3, r13_2, r14_1])),
    assertz(diagonal([r08_8, r09_7, r10_6, r11_5, r12_4, r13_3, r14_2, r15_1])),
    assertz(column([r08_1])),
    assertz(column([r07_1, r09_1])),
    assertz(column([r06_1, r08_2, r10_1])),
    assertz(column([r05_1, r07_2, r09_2, r11_1])),
    assertz(column([r04_1, r06_2, r08_3, r10_2, r12_1])),
    assertz(column([r03_1, r05_2, r07_3, r09_3, r11_2, r13_1])),
    assertz(column([r02_1, r04_2, r06_3, r08_4, r10_3, r12_2, r14_1])),
    assertz(column([r01_1, r03_2, r05_3, r07_4, r09_4, r11_3, r13_2, r15_1])),
    assertz(column([r02_2, r04_3, r06_4, r08_5, r10_4, r12_3, r14_2])),
    assertz(column([r03_3, r05_4, r07_5, r09_5, r11_4, r13_3])),
    assertz(column([r04_4, r06_5, r08_6, r10_5, r12_4])),
    assertz(column([r05_5, r07_6, r09_6, r11_5])),
    assertz(column([r06_6, r08_7, r10_6])),
    assertz(column([r07_7, r09_7])),
    assertz(column([r08_8])),
    assertz(diagonal([r08_1, r09_1, r10_1, r11_1, r12_1, r13_1, r14_1, r15_1])),
    assertz(diagonal([r07_1, r08_2, r09_2, r10_2, r11_2, r12_2, r13_2, r14_2])),
    assertz(diagonal([r06_1, r07_2, r08_3, r09_3, r10_3, r11_3, r12_3, r13_3])),
    assertz(diagonal([r05_1, r06_2, r07_3, r08_4, r09_4, r10_4, r11_4, r12_4])),
    assertz(diagonal([r04_1, r05_2, r06_3, r07_4, r08_5, r09_5, r10_5, r11_5])),
    assertz(diagonal([r03_1, r04_2, r05_3, r06_4, r07_5, r08_6, r09_6, r10_6])),
    assertz(diagonal([r02_1, r03_2, r04_3, r05_4, r06_5, r07_6, r08_7, r09_7])),
    assertz(diagonal([r01_1, r02_2, r03_3, r04_4, r05_5, r06_6, r07_7, r08_8])).


% Definindo o predicado para desenhar o tabuleiro com as árvores
draw_line([]) :- nl.

draw_line([Coord|Rest]) :-
    (trees(Color, Size, Coord) -> draw_color_square(Color, Size), draw_line(Rest); write(Coord), draw_line(Rest)).

draw_color_square(Color, Size) :-
    (   
        Color = ' ' ->
        write('( '),
        write(Color),
        write(Size),
        write(')')
    ; 
        write('('),
        write(Size),
        write(Color),
        write(')')
    ).

draw_board :-   nl,
                draw_line(['                            | ', r01_1, ' |']),
                draw_line(['                        | ', r02_1, ' | ',r02_2, ' |']),
                draw_line(['                    | ', r03_1, ' | ',r03_2, ' | ',r03_3, ' |']),
                draw_line(['                | ', r04_1, ' | ', r04_2, ' | ', r04_3, ' | ', r04_4, ' |']),
                draw_line(['            | ', r05_1, ' | ', r05_2, ' | ', r05_3, ' | ', r05_4, ' | ', r05_5, ' |']),
                draw_line(['        | ', r06_1, ' | ', r06_2, ' | ', r06_3, ' | ', r06_4, ' | ', r06_5, ' | ', r06_6, ' |']),
                draw_line(['    | ', r07_1, ' | ', r07_2, ' | ', r07_3, ' | ', r07_4, ' | ', r07_5, ' | ', r07_6, ' | ', r07_7, ' |']),
                draw_line(['| ', r08_1, ' | ', r08_2, ' | ', r08_3, ' | ', r08_4, ' | ', r08_5, ' | ', r08_6, ' | ', r08_7, ' | ', r08_8, ' |']),
                draw_line(['    | ', r09_1, ' | ', r09_2, ' | ', r09_3, ' | ', r09_4, ' | ', r09_5, ' | ', r09_6, ' | ', r09_7, ' |']),
                draw_line(['        | ', r10_1, ' | ', r10_2, ' | ', r10_3, ' | ', r10_4, ' | ', r10_5, ' | ', r10_6, ' |']),
                draw_line(['            | ', r11_1, ' | ', r11_2, ' | ', r11_3, ' | ', r11_4, ' | ', r11_5, ' |']),
                draw_line(['                | ', r12_1, ' | ', r12_2, ' | ', r12_3, ' | ', r12_4, ' |']),
                draw_line(['                    | ', r13_1, ' | ', r13_2, ' | ', r13_3, ' |']),
                draw_line(['                        | ', r14_1, ' | ', r14_2, ' |']),
                draw_line(['                            | ', r15_1, ' |']).





% Exemplo de uso:
% ?- play.

