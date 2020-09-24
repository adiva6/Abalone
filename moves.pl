% -------------------------------------------------------------------------------
% Import board utilities
:- [board].
% -------------------------------------------------------------------------------

% Matches for legal destinations given the current board state and
% the location of the marble to move.
possible_moves(Player, BoardState, SourceRow, SourceCol, DestRow, DestCol):-
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
