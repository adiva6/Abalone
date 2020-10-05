% -------------------------------------------------------------------------------
% In all of the following heuristics, the player with black marbles is
% considered as the max player
% -------------------------------------------------------------------------------

% -------------------------------------------------------------------------------
% Import necessary board utilities
:- [board].
% -------------------------------------------------------------------------------

% Heuristic value is based on the sum of centerability and killability scores
total_heuristic_score(BoardState, HeuristicValue):-
    centerability_score(BoardState, CenterabilityScore),
    killability_score(BoardState, KillabilityScore),
    HeuristicValue is CenterabilityScore + (100 ** KillabilityScore), !.

% Level of centerability, based on distance from center of each player's balls
centerability_score(BoardState, HeuristicValue):-
    board_size(BoardSize),
    BoardCenter is ceil(BoardSize / 2),
    findall(RowIndex:ColIndex, black_ball(BoardState, RowIndex, ColIndex), BlackLocations),
    findall(RowIndex:ColIndex, white_ball(BoardState, RowIndex, ColIndex), WhiteLocations),
    calculate_distance_from_center(BoardCenter, BlackLocations, BlackDistance),
    calculate_distance_from_center(BoardCenter, WhiteLocations, WhiteDistance),
    HeuristicValue is BlackDistance - WhiteDistance.

% Get a list of locations and sum up their distances from the center
% of the board
calculate_distance_from_center(BoardCenter, Locations, TotalDistance):-
    calculate_distance_from_center(BoardCenter, Locations, 0, TotalDistance).

calculate_distance_from_center(BoardCenter, [CurrLocation|Locations], RestOfDistance, TotalDistance):-
    CurrLocation = RowIndex:ColIndex,
    CurrLocationDistance is abs(RowIndex - BoardCenter) + abs(ColIndex - BoardCenter),
    CurrTotalDistance is CurrLocationDistance + RestOfDistance,
    calculate_distance_from_center(BoardCenter, Locations, CurrTotalDistance, TotalDistance).

calculate_distance_from_center(_, [], TotalDistance, TotalDistance):- !.

% Level of killability, based on the score of each player
killability_score(BoardState, HeuristicValue):-
    score(black, BoardState, BlackScore),
    score(white, BoardState, WhiteScore),
    HeuristicValue is BlackScore - WhiteScore.
