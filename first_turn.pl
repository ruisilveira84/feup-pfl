% Predicado para atualizar o estado do jogo
update_board(NewGameState, UpdatedGameState) :-
    retractall(state(_)),
    assertz(state(NewGameState)),
    update_tree_database(NewGameState), % Atualiza a base de dados com as árvores
    UpdatedGameState = NewGameState.

% Predicado para atualizar a base de dados com as árvores
update_tree_database([]).
update_tree_database([(Color, Size, Coord)|Rest]) :-
    (
        % Verifica se já existe uma árvore na coordenada
        trees(OldColor, OldSize, Coord)
    ->
        % Se existir, guarda os dados globalmente
        retractall(last_tree(_,_)),
        assertz(last_tree(OldColor, OldSize)),
        % Atualiza a base de dados com a nova árvore
        retractall(trees(_, _, Coord)),
        assertz(trees(Color, Size, Coord))
    ;
        % Se não existir, apenas atualiza a base de dados com a nova árvore
        assertz(trees(Color, Size, Coord))
    ),
    update_tree_database(Rest).
