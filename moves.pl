% -------------------------------------------------------------------------------
% Import board utilities
:- [board].
% -------------------------------------------------------------------------------

% Matches for legal destinations given the current board state and
% the location of the marble to move.
possible_moves(Player, BoardState, SourceRow, SourceCol, DestRow, DestCol):-
    Direction = direction(MoveX, MoveY),
    DestRow is SourceRow + MoveX,
    DestCol is SourceCol + MoveY,
    legal_move(Player, BoardState, SourceRow, SourceCol, DestRow, DestCol, Direction).
