% -------------------------------------------------------------------------------
:- [heuristics, board].
% -------------------------------------------------------------------------------

alphabeta(Player, Depth, BoardState, Alpha, Beta, GoodState, Val):-
    Depth > 0,
    possible_states(Player, BoardState, PossibleStates), !,
    NewDepth is Depth - 1,
    boundedbest(Player, NewDepth, PossibleStates, Alpha, Beta, GoodState, Val);
    centerability_score(BoardState, Val).

boundedbest(Player, Depth, [BoardState|PossibleStates], Alpha, Beta, GoodState, GoodVal) :-
    other_player(Player, OtherPlayer),
    alphabeta(OtherPlayer, Depth, BoardState, Alpha, Beta, _, Val),
    goodenough(Depth, PossibleStates, Alpha, Beta, BoardState, Val, GoodState, GoodVal).

goodenough(_, [], _, _, BoardState, Val, BoardState, Val):- !. % No other candidate
goodenough(_, _, Alpha, Beta, BoardState, Val, BoardState, Val):-
    min_to_move(BoardState), Val > Beta, !; % Maximizer attained upper bound
    max_to_move(BoardState), Val < Alpha, !. % Minimizer attained lower bound

goodenough(Depth, PossibleStates, Alpha, Beta, BoardState, Val, GoodState, GoodVal):-
    newbounds(Alpha, Beta, BoardState, Val, NewAlpha, NewBeta), % Refine bounds
    boundedbest(Depth, PossibleStates, NewAlpha, NewBeta, BoardState1, Val1),
    betterof(BoardState, Val, BoardState1, Val1, GoodState, GoodVal).

newbounds(Alpha, Beta, BoardState, Val, Val, Beta):-
    min_to_move(BoardState), Val > Alpha, !. % Maximizer increased lower bound

newbounds(Alpha, Beta, BoardState, Val, Alpha, Val):-
    max_to_move(BoardState), Val < Beta, !. % Minimizer decreased upper bound

newbounds(Alpha, Beta, _, _, Alpha, Beta).

betterof(BoardState, Val, _, Val1, BoardState, Val):-
    min_to_move(BoardState), Val > Val1, !;
    max_to_move(BoardState), Val < Val1, !.

betterof(_, _, BoardState, Val1, BoardState, Val1).