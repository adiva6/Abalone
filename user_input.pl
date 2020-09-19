pick_board_size(BoardSize):-
    writeln("Please select a board size (must be an odd number between 5 and 17):"),
    repeat,
    read(X),
    (
        integer(X),
        X >= 5,
        X =< 17,
        Remainder is mod(X, 2),
        Remainder = 1,
        BoardSize = X, !;
        writeln("Invalid input. Please enter a valid board size."),
        fail
    ).


