% % level of centerability, based on distance from center of each player's balls
% % score will be stored in db and changed along with board state
% centerability_score(BlackScore, WhiteScore).

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


% % Move is move(Balls, Direction), Balls are all balls which change positions in move (1 to 5)
% % considers moved balls and their surroundings, rest of board does not change much
% % uses all heuristics scores of both players
% move_score(Move, Score).
