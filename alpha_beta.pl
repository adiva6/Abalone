% -------------------------------------------------------------------------------
% Import heuristic
:- [heuristics].
% -------------------------------------------------------------------------------

alphabeta(Depth, Pos, Alpha, Beta, GoodPos, Val):-
    Depth > 0,
    moves(Pos, Poslist), !,
    NewDepth is Depth - 1,
    boundedbest(NewDepth, Poslist, Alpha, Beta, GoodPos, Val);
    board_size(BoardSize),
    centerability_score(BoardSize, Pos, Val).

boundedbest(Depth, [Pos|Poslist], Alpha, Beta, GoodPos, GoodVal) :-
    alphabeta(Depth, Pos, Alpha, Beta, _, Val),
    goodenough(Depth, Poslist, Alpha, Beta, Pos, Val, GoodPos, GoodVal).

goodenough(_, [], _, _, Pos, Val, Pos, Val):- !. % No other candidate
goodenough(_, _, Alpha, Beta, Pos, Val, Pos, Val):-
    min_to_move(Pos), Val > Beta, !; % Maximizer attained upper bound
    max_to_move(Pos), Val < Alpha, !. % Minimizer attained lower bound

goodenough(Depth, Poslist, Alpha, Beta, Pos, Val, GoodPos, GoodVal):-
    newbounds(Alpha, Beta, Pos, Val, NewAlpha, NewBeta), % Refine bounds
    boundedbest(Depth, Poslist, NewAlpha, NewBeta, Pos1, Val1),
    betterof(Pos, Val, Pos1, Val1, GoodPos, GoodVal).

newbounds(Alpha, Beta, Pos, Val, Val, Beta):-
    min_to_move(Pos), Val > Alpha, !. % Maximizer increased lower bound

newbounds(Alpha, Beta, Pos, Val, Alpha, Val):-
    max_to_move(Pos), Val < Beta, !. % Minimizer decreased upper bound

newbounds(Alpha, Beta, _, _, Alpha, Beta).

betterof(Pos, Val, _, Val1, Pos, Val):-
    min_to_move(Pos), Val > Val1, !;
    max_to_move(Pos), Val < Val1, !.

betterof(_, _, Pos1, Val1, Pos1, Val1).