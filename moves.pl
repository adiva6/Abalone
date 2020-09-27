% -------------------------------------------------------------------------------
% Import board utilities
:- [board].
% -------------------------------------------------------------------------------

% Matches for legal destinations given the current board state and
% the location of the marble to move.
possible_moves_by_location(Player, BoardState, SourceRow, SourceCol, DestRow, DestCol, direction(X, Y)):-
    direction(X, Y),
    possible_moves_by_direction(Player, BoardState, SourceRow, SourceCol, DestRow, DestCol, direction(X, Y)).

% Matches for a legal destination for a certain direction.
possible_moves_by_direction(Player, BoardState, SourceRow, SourceCol, DestRow, DestCol, Direction):-
    next_slot_location(SourceRow, SourceCol, Direction, DestRow, DestCol),
    legal_move(Player, BoardState, SourceRow, SourceCol, Direction).

% Matches for the slots following the location of the moving marble, according to the
% given direction.
slots_sequence_by_direction(BoardState, BoardSize, SourceRow, SourceCol, Direction, [SlotType|SlotTypes]):-
    between(0, BoardSize, SourceRow),
    between(0, BoardSize, SourceCol), !,
    slot_by_index(BoardState, SourceRow, SourceCol, SlotType),
    next_slot_location(SourceRow, SourceCol, Direction, NextRowIndex, NextColIndex),
    slots_sequence_by_direction(BoardState, BoardSize, NextRowIndex, NextColIndex, Direction, SlotTypes), !.

slots_sequence_by_direction(_, BoardSize, SourceRow, SourceCol, _, []):-
    not(between(0, BoardSize, SourceRow));
    not(between(0, BoardSize, SourceCol)).

% True if moving the marble in the source location towards the given direction
% is considered a legal move.
legal_move(Player, BoardState, SourceRow, SourceCol, Direction):-
    board_size(BoardSize),
    between(1, BoardSize, SourceRow),
    between(1, BoardSize, SourceCol),
    slots_sequence_by_direction(BoardState, BoardSize, SourceRow, SourceCol, Direction, Slots),
    legal_move(Player, Slots).

legal_move(PlayerColor, [PlayerBall, PlayerBall, PlayerBall, OtherPlayerBall, OtherPlayerBall, NoBall | _]):-
    validate_colors(PlayerColor, PlayerBall,OtherPlayerBall, NoBall, _).

legal_move(PlayerColor, [PlayerBall, PlayerBall, PlayerBall, OtherPlayerBall, OtherPlayerBall, Border | _]):-
    validate_colors(PlayerColor, PlayerBall,OtherPlayerBall, _, Border).

legal_move(PlayerColor, [PlayerBall, PlayerBall, PlayerBall, OtherPlayerBall, NoBall | _]):-
    validate_colors(PlayerColor, PlayerBall,OtherPlayerBall, NoBall, _).

legal_move(PlayerColor, [PlayerBall, PlayerBall, PlayerBall, OtherPlayerBall, Border | _]):-
    validate_colors(PlayerColor, PlayerBall,OtherPlayerBall, _, Border).

legal_move(PlayerColor, [PlayerBall, PlayerBall, PlayerBall, NoBall | _]):-
    validate_colors(PlayerColor, PlayerBall, _, NoBall, _).

legal_move(PlayerColor, [PlayerBall, PlayerBall, OtherPlayerBall, NoBall | _]):-
    validate_colors(PlayerColor, PlayerBall,OtherPlayerBall, NoBall, _).

legal_move(PlayerColor, [PlayerBall, PlayerBall, OtherPlayerBall, Border | _]):-
    validate_colors(PlayerColor, PlayerBall,OtherPlayerBall, _, Border).

legal_move(PlayerColor, [PlayerBall, PlayerBall, NoBall | _]):-
    validate_colors(PlayerColor, PlayerBall, _, NoBall, _).

legal_move(PlayerColor, [PlayerBall, NoBall | _]):-
    validate_colors(PlayerColor, PlayerBall, _, NoBall, _).

validate_colors(PlayerColor, PlayerBall, OtherPlayerBall, NoBall, Border):-
    slot_legend(PlayerBall, PlayerColor),
    slot_legend(NoBall, empty),
    slot_legend(Border, border),
    other_player(PlayerColor, OtherPlayer),
    slot_legend(OtherPlayerBall, OtherPlayer).

% TODO
% % alters board state and player scores if necessary
% make_move(move(FirstBall, Direction)).

% % TODO
% % a "move" object, defines a legal move
% move(BoardState, PlayerColor, RowIndex, ColIndex, Direction, NextBoardState).
