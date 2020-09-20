% -------------------------------------------------------------------------------
% Import board utilities and moves predicates
:- [board, moves].
% -------------------------------------------------------------------------------

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

pick_ball_to_move(BoardState, Player, Row, Column):-
    board_size(BoardSize),
    writeln("Pick a ball to move. The ball will push other balls in the direction you choose."),
    writeln("Row number:"),
    repeat,
    (
        pick_row_number(BoardSize, Row),
        writeln("Column letter:"),
        pick_col_number(BoardSize, Column),
        slot_by_index(BoardState, Row, Column, Player), !;
        writeln("Invalid input. Please pick a ball as your color."),
        fail
    ).

pick_row_number(BoardSize, Row):-
    repeat,
    (
        get_code(UserInput),
        between(1, BoardSize),
        Row = UserInput, !;
        writeln("Invalid input. Please enter a valid row number."),
        fail
    ).

pick_col_number(BoardSize, Col):-
    repeat,
    (
        get_code(UserInput),
        UpperLimit is 65 + BoardSize,
        between(65, UpperLimit),
        Col is UserInput - 64, !;
        writeln("Invalid input. Please enter a valid column letter."),
        fail
    ).

pick_possible_move(BoardState, Player, Row, Column, DestRow, DestCol):-
    findall(PossibleRow:PossibleCol,
            possible_moves(Player, BoardState, Row, Column, PossibleRow, PossibleCol),
            PossibleMoves),
    writeln("Pick a move from the following:"),
    length(PossibleMoves, MovesAmount),
    letter_to_row(ColumnLetter, Column),
    print_moves(1, Row, ColumnLetter, PossibleMoves),
    repeat,
    (
        get_code(UserInput),
        between(1, MovesAmount),
        MoveIndex is UserInput - 1,
        nth0(MoveIndex, PossibleMoves, DestRow:DestCol), !;
        writeln("Invalid input. Please pick one of the moves above."),
        fail
    ).

print_moves(MoveIndex, SourceRow, SourceColLetter, [CurrentMove|Moves]):-
    CurrentMove = PossibleRow:PossibleCol,
    write(MoveIndex), write(": "),
    letter_to_row(PossibleColLetter, PossibleCol),
    nl,
    write(SourceRow), write(SourceColLetter), write(" -> "),
    write(PossibleRow), write(PossibleColLetter),
    nl,
    NextMoveIndex is MoveIndex + 1,
    print_moves(NextMoveIndex, SourceRow, SourceColLetter, Moves).

print_moves(_, _, _, []):- !.