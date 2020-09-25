% -------------------------------------------------------------------------------
% Import board utilities and moves predicates
:- [board, moves].
% -------------------------------------------------------------------------------

% Get the board size as input from the user
pick_board_size(BoardSize):-
    writeln("Please select a board size (must be an odd number between 7 and 17):"),
    repeat,
    read(UserInput),
    (
        integer(UserInput),
        between(7, 17, UserInput),
        Remainder is mod(UserInput, 2),
        Remainder = 1,
        BoardSize = UserInput,
        retractall(board_size(_)),
        assert(board_size(BoardSize)), 
        !;
        writeln("Invalid input. Please enter a valid board size."),
        fail
    ).

% Get the difficulty level as input from the user
pick_difficulty_level(Level):-
    writeln("Please select a difficulty level:"),
    writeln("1: Beginner"),
    writeln("2: Intermediate"),
    writeln("3: Expert"),
    repeat,
    get_single_char(UserInputCode),
    number_codes(UserInput, [UserInputCode]),
    (
        (UserInput = 1, Level = easy), !;
        (UserInput = 2, Level = intermediate), !;
        (UserInput = 3, Level = expert), !,
        retractall(difficulty_level(_)),
        assert(difficulty_level(Level)), !;
        writeln("Invalid input. Please enter a valid difficulty level."),
        fail
    ).

% Get the location of the ball the player chooses to move next. The ball chosen
% will be the one that pushes the other balls in the convoy (if there are any).
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

% Get a valid row number from the user. It must be within the
% bounds of the board.
pick_row_number(BoardSize, Row):-
    repeat,
    (
        read(UserInput),
        between(1, BoardSize, UserInput),
        Row = UserInput, !;
        writeln("Invalid input. Please enter a valid row number."),
        fail
    ).

% Get a valid column number from the user. It must be within the
% bounds of the board.
pick_col_number(BoardSize, Col):-
    repeat,
    (
        read(UserInput),
        UpperLimit is 65 + BoardSize,
        between(65, UpperLimit, UserInput),
        Col is UserInput - 64, !;
        writeln("Invalid input. Please enter a valid column letter."),
        fail
    ).

% Present all possible moves for the current player given the ball he chose to move.
% DestRow and DestCol will match the location to which the player chose to move
% the ball to.
pick_possible_move(BoardState, Player, Row, Column, DestRow, DestCol):-
    findall(PossibleRow:PossibleCol,
            possible_moves(Player, BoardState, Row, Column, PossibleRow, PossibleCol),
            PossibleMoves),
    writeln("Pick a move from the following:"),
    length(PossibleMoves, MovesAmount),
    col_num_to_letter(Column, ColumnLetter),
    print_moves(1, Row, ColumnLetter, PossibleMoves),
    repeat,
    (
        get_single_char(UserInputCode),
        number_codes(UserInput, [UserInputCode]),
        between(1, MovesAmount, UserInput),
        MoveIndex is UserInput - 1,
        nth0(MoveIndex, PossibleMoves, DestRow:DestCol), !;
        writeln("Invalid input. Please pick one of the moves above."),
        fail
    ).

% Display a list of given moves as an indexed list
print_moves(MoveIndex, SourceRow, SourceColLetter, [CurrentMove|Moves]):-
    CurrentMove = PossibleRow:PossibleCol,
    write(MoveIndex), write(": "),
    col_num_to_letter(PossibleCol, PossibleColLetter),
    write(SourceRow), write(SourceColLetter), write(" -> "),
    write(PossibleRow), write(PossibleColLetter),
    nl,
    NextMoveIndex is MoveIndex + 1,
    print_moves(NextMoveIndex, SourceRow, SourceColLetter, Moves), !.

print_moves(_, _, _, []):- !.
