% -------------------------------------------------------------------------------
% In all of the following heuristics, the player with black marbles is
% considered as the max player
% -------------------------------------------------------------------------------

% Use all heuristics to determine how good is the move
calculate_total_diff(RowIndex, ColIndex, Direction, SlotTypes, NextSlotTypes, ScoreDiff):-
    board_size(BoardSize),
    BoardCenter is ceil(BoardSize / 2),
    calculate_centerability_diff(BoardCenter, RowIndex, ColIndex, Direction, SlotTypes, NextSlotTypes, 0, CenterabilityDiff),
    calculate_kill_diff(SlotTypes, KillabilityDiff), !,
    ScoreDiff is CenterabilityDiff + KillabilityDiff.

% Check if move kills (using 'killer_move' predict) & Return heuristic points accordingly
calculate_kill_diff(SlotTypes, KillabilityDiff):-
    SlotTypes = [FirstSlotType|_],
    slot_legend(FirstSlotType, CurrPlayer),
    (
        killer_move(CurrPlayer, SlotTypes),
        (
            max_to_move(CurrPlayer), !, 
            KillabilityDiff = 1000
            ;
            KillabilityDiff = -1000, !
        );
        KillabilityDiff = 0
    ).

% Calculate the diff between two states (represented by curr/next sequence changed by move)
calculate_centerability_diff(BoardCenter, RowIndex, ColIndex, Direction, 
                     [CurrSlotType|CurrSlotTypes], [_|NextSlotTypes], CurrScoreDiff, FinalScoreDiff):-
    CurrSlotType \= 0 , CurrSlotType \= -1, !,
    next_slot_location(RowIndex, ColIndex, Direction, NextRowIndex, NextColIndex),
    calculate_location_score(BoardCenter, RowIndex:ColIndex, CurrDistance),
    calculate_location_score(BoardCenter, NextRowIndex:NextColIndex, NextDistance),

    % Add/Reduce distances diff, depending on the player who owns the ball
    slot_legend(CurrSlotType, Player),
    (
        max_to_move(Player), 
        % Subtract current diff from current total diff if ball is owned by max player
        % Distance from center is bad,
        % So more distance from center of max player's ball translates to points for min player.
        NextScoreDiff is CurrScoreDiff - (NextDistance - CurrDistance), !
        ; 
        NextScoreDiff is CurrScoreDiff + (NextDistance - CurrDistance), !
    ),
    calculate_centerability_diff(
        BoardCenter, NextRowIndex, NextColIndex, Direction, CurrSlotTypes, NextSlotTypes, NextScoreDiff, FinalScoreDiff
    ).

calculate_centerability_diff(_, _, _, _, [0|_], _, FinalScoreDiff, FinalScoreDiff):- !.
calculate_centerability_diff(_, _, _, _, [-1|_], _, FinalScoreDiff, FinalScoreDiff):- !.
                        
   
% Get a location and calculate it's distance score from the center of the board
calculate_location_score(BoardCenter, RowIndex:ColIndex, Score):-
    Score is abs(RowIndex - BoardCenter) + abs(ColIndex - BoardCenter).

min_to_move(white).
max_to_move(black).