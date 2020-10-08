alphabeta(Player, Depth, BoardState:Val, Alpha, Beta, GoodState:GoodVal):-
    Depth > 0,
    possible_states(Player, BoardState:Val, PossibleStates), !,
    NewDepth is Depth - 1,
    boundedbest(Player, NewDepth, PossibleStates, Alpha, Beta, GoodState:GoodVal);
    GoodVal = Val.

boundedbest(Player, Depth, [BoardState:Points|PossibleStates], Alpha, Beta, GoodState:GoodVal):-
    other_player(Player, OtherPlayer),
    alphabeta(OtherPlayer, Depth, BoardState:Points, Alpha, Beta, _:Val),
    goodenough(Player, Depth, PossibleStates, Alpha, Beta, BoardState:Val, GoodState:GoodVal).

goodenough(_, _, [], _, _, BoardState:Val, BoardState:Val):- !. % No other candidate
goodenough(Player, _, _, Alpha, Beta, BoardState:Val, BoardState:Val):-
    min_to_move(Player), Val > Beta, !; % Maximizer attained upper bound
    max_to_move(Player), Val < Alpha, !. % Minimizer attained lower bound

goodenough(Player, Depth, PossibleStates, Alpha, Beta, BoardState:Val, GoodState:GoodVal):-
    newbounds(Player, Alpha, Beta, Val, NewAlpha, NewBeta), % Refine bounds
    boundedbest(Player, Depth, PossibleStates, NewAlpha, NewBeta, BoardState1:Val1),
    betterof(Player, BoardState:Val, BoardState1:Val1, GoodState:GoodVal).

newbounds(Player, Alpha, Beta, Val, Val, Beta):-
    min_to_move(Player), Val > Alpha, !. % Maximizer increased lower bound

newbounds(Player, Alpha, Beta, Val, Alpha, Val):-
    max_to_move(Player), Val < Beta, !. % Minimizer decreased upper bound

newbounds(_, Alpha, Beta, _, Alpha, Beta).

betterof(Player, BoardState:Val, _:Val1, BoardState:Val):-
    min_to_move(Player), Val < Val1, !;
    max_to_move(Player), Val > Val1, !.

betterof(_, _, BoardState:Val1, BoardState:Val1).
