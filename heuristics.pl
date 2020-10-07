% -------------------------------------------------------------------------------
% In all of the following heuristics, the player with black marbles is
% considered as the max player
% -------------------------------------------------------------------------------

% Heuristic value is based on the sum of centerability and killability scores
total_heuristic_score(BoardState, HeuristicValue):-
    centerability_score(BoardState, CenterabilityScore),
    killability_score(BoardState, KillabilityScore),
    HeuristicValue is CenterabilityScore + (100 * KillabilityScore), !.

calculate_score_diff(RowIndex, ColIndex, Direction, SlotTypes, NextSlotTypes, ScoreDiff):-
    board_size(BoardSize),
    BoardCenter is ceil(BoardSize / 2),
    calculate_score_diff(BoardCenter, RowIndex, ColIndex, Direction, SlotTypes, NextSlotTypes, 0, ScoreDiff).

calculate_score_diff(BoardCenter, RowIndex, ColIndex, Direction, 
                     [SlotType|SlotTypes], [_|NextSlotTypes], CurrScoreDiff, FinalScoreDiff):-
    SlotType \= 0 , SlotType \= -1,
    next_slot_location(RowIndex, ColIndex, Direction, NextRowIndex, NextColIndex),
    calculate_location_score(BoardCenter, RowIndex:ColIndex, CurrDistance),
    calculate_location_score(BoardCenter, NextRowIndex:NextColIndex, NextDistance),
    slot_legend(SlotType, Player),
    (
        max_to_move(Player), 
        NextScoreDiff is CurrScoreDiff + (NextDistance - CurrDistance), !
        ; 
        NextScoreDiff is CurrScoreDiff - (NextDistance - CurrDistance), !
    ),
    calculate_score_diff(
        BoardCenter, NextRowIndex, NextColIndex, Direction, SlotTypes, NextSlotTypes, NextScoreDiff, FinalScoreDiff
    ).

calculate_score_diff(_, _, _, _, [0|_], _, FinalScoreDiff, FinalScoreDiff).
calculate_score_diff(_, _, _, _, [-1|_], _, FinalScoreDiff, FinalScoreDiff).
                        
   
% Get a location and calculate it's distance score from the center of the board
calculate_location_score(BoardCenter, RowIndex:ColIndex, Score):-
    Score is abs(RowIndex - BoardCenter) + abs(ColIndex - BoardCenter).

% Level of killability, based on the score of each player
killability_score(BoardState, HeuristicValue):-
    score(black, BoardState, BlackScore),
    score(white, BoardState, WhiteScore),
    ExpBlackScore is 2 ** BlackScore,
    ExpWhiteScore is 2 ** WhiteScore,
    HeuristicValue is ExpBlackScore - ExpWhiteScore, !.

min_to_move(Player):-
    Player = white.

max_to_move(Player):-
    Player = black.