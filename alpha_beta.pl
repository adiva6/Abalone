% -------------------------------------------------------------------------------
% Import necessary modules
:- [heuristics, board, moves, utils].
% -------------------------------------------------------------------------------

alphabeta(Player, Depth, BoardState, Alpha, Beta, GoodState, Val):-
    Depth > 0,
    possible_states(Player, BoardState, PossibleStates), !,
    NewDepth is Depth - 1,
    Alpha1 is -Beta,
    Beta1 is -Alpha,
    boundedbest(Player, NewDepth, PossibleStates, Alpha1, Beta1, GoodState, Val);
    total_heuristic_score(BoardState, Val).

boundedbest(Player, Depth, [BoardState|PossibleStates], Alpha, Beta, GoodState, GoodVal):-
    other_player(Player, OtherPlayer),
    alphabeta(OtherPlayer, Depth, BoardState, Alpha, Beta, _, MinusVal),
    Val is -MinusVal,
    goodenough(Player, Depth, PossibleStates, Alpha, Beta, BoardState, Val, GoodState, GoodVal).

goodenough(_, _, [], _, _, BoardState, Val, BoardState, Val):- !. % No other candidate
goodenough(Player, _, _, Alpha, Beta, BoardState, Val, BoardState, Val):-
    min_to_move(Player), Val > Beta, !; % Maximizer attained upper bound
    max_to_move(Player), Val < Alpha, !. % Minimizer attained lower bound

goodenough(Player, Depth, PossibleStates, Alpha, Beta, BoardState, Val, GoodState, GoodVal):-
    newbounds(Player, Alpha, Beta, BoardState, Val, NewAlpha, NewBeta), % Refine bounds
    boundedbest(Player, Depth, PossibleStates, NewAlpha, NewBeta, BoardState1, Val1),
    betterof(Player, BoardState, Val, BoardState1, Val1, GoodState, GoodVal).

newbounds(Player, Alpha, Beta, _, Val, Val, Beta):-
    min_to_move(Player), Val > Alpha, !. % Maximizer increased lower bound

newbounds(Player, Alpha, Beta, _, Val, Alpha, Val):-
    max_to_move(Player), Val < Beta, !. % Minimizer decreased upper bound

newbounds(_, Alpha, Beta, _, _, Alpha, Beta).

betterof(Player, BoardState, Val, _, Val1, BoardState, Val):-
    min_to_move(Player), Val > Val1, !;
    max_to_move(Player), Val < Val1, !.

betterof(_, _, _, BoardState, Val1, BoardState, Val1).

min_to_move(Player):-
    Player = white.

max_to_move(Player):-
    Player = black.