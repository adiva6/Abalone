% Get the board size as input from the user
pick_board_size(BoardSize):-
    writeln("Please select a board size (must be an odd number between 5 and 17):"),
    repeat,
    read(UserInput),
    (
        integer(UserInput),
        UserInput >= 5,
        UserInput =< 17,
        Remainder is mod(UserInput, 2),
        Remainder = 1,
        BoardSize = UserInput, !;
        writeln("Invalid input. Please enter a valid board size."),
        fail
    ).

% Get the difficulty level as input from the user
pick_difficulty_level(Level):-
    writeln("Please select a difficulty level:"),
    writeln("1- Beginner"),
    writeln("2- Intermediate"),
    writeln("3- Expert"),
    repeat,
    read(UserInput),
    (
        integer(UserInput),
        (UserInput = 1, Level = easy), !;
        (UserInput = 2, Level = intermediate), !;
        (UserInput = 3, Level = expert), !;
        writeln("Invalid input. Please enter a valid difficulty level."),
        fail
    ).