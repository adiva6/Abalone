% -------------------------------------------------------------------------------
% In all of the following heuristics, the player with black marbles is
% considered as the max player
% -------------------------------------------------------------------------------

% -------------------------------------------------------------------------------
% Import necessary board utilities
:- [board].
% -------------------------------------------------------------------------------

% Level of centerability, based on distance from center of each player's balls
% Score will be stored in db and changed along with board state
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

% % level of threeability, based on number of triples in a row of each player's balls
% % score will be stored in db and changed along with board state
% threeability_score(BlackScore, WhiteScore).

% % level of groupability, based on number of common edges between each player's balls
% % score will be stored in db and changed along with board state
% groupability_score(BlackScore, WhiteScore).

% % the heuristic for a move's centerability
% centerability_diff(Move, BlackScoreDiff, WhiteScoreDiff).

% % the heuristic for a move's threeability
% threeability_diff(Move, BlackScoreDiff, WhiteScoreDiff).

% % the heuristic for a move's groupability
% groupability_diff(Move, BlackScoreDiff, WhiteScoreDiff).

% % the heuristic for a move's killability (ability to kill without getting killed)
% killability_diff(Move, BlackScoreDiff, WhiteScoreDiff).
