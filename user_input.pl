% Get the board size as input from the user
pick_board_size(BoardSize):-
    writeln("Please select a board size (must be an odd number between 7 and 17):"),
    repeat,
    read_string(UserInput),
    (
        number_string(UserInputNumber, UserInput),
        between(7, 17, UserInputNumber),
        Remainder is mod(UserInputNumber, 2),
        Remainder = 1,
        BoardSize = UserInputNumber,
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
    (
        read_string(UserInput),
        number_string(UserInputNumber, UserInput),
        between(1, 3, UserInputNumber), !,
        retractall(difficulty_level(_)),
        assert(difficulty_level(UserInputNumber)),
        Level = UserInputNumber, !;
        writeln("Invalid input. Please enter a valid difficulty level."),
        fail
    ).

% Get the location of the ball the player chooses to move next. The ball chosen
% will be the one that pushes the other balls in the convoy (if there are any).
pick_ball_to_move(BoardState, Player, Row, Column):-
    board_size(BoardSize),
    writeln("Pick a ball to move. The ball will push other balls in the direction you choose."),
    repeat,
    (
        writeln("Row number:"),
        pick_row_number(BoardSize, Row),
        writeln("Column letter:"),
        pick_col_number(BoardSize, Column),
        slot_legend(BallColor, Player),
        slot_by_index(BoardState, Row, Column, BallColor), !;
        writeln("Invalid input. Please pick a ball as your color."),
        fail
    ).

% Get a valid row number from the user. It must be within the
% bounds of the board.
pick_row_number(BoardSize, Row):-
    repeat,
    (
        read_string(UserInput),
        number_string(UserInputNumber, UserInput),
        between(1, BoardSize, UserInputNumber),
        Row = UserInputNumber, !;
        writeln("Invalid input. Please enter a valid row number."),
        fail
    ).

% Get a valid column number from the user. It must be within the
% bounds of the board.
pick_col_number(BoardSize, Col):-
    repeat,
    (
        read_string(UserInput),
        string_length(UserInput, 1),
        char_code(UserInput, UserInputCode),
        UpperLimit is 65 + BoardSize,
        between(65, UpperLimit, UserInputCode),
        letter_to_col_num(UserInput, Col), !;
        writeln("Invalid input. Please enter a valid column letter."),
        fail
    ).

% Present all possible moves for the current player given the ball he chose to move.
% DestRow and DestCol will match the location to which the player chose to move
% the ball to.
pick_possible_move(BoardState, Player, Row, Column, Direction):-
    findall(
        PossibleDirection-(PossibleRow:PossibleCol),
        possible_moves_by_location(Player, BoardState, Row, Column, PossibleRow, PossibleCol, PossibleDirection),
        PossibleMoves
    ),
    writeln("Pick a move from the following:"),
    length(PossibleMoves, MovesAmount),
    col_num_to_letter(Column, ColumnLetter),
    print_moves(1, Row, ColumnLetter, PossibleMoves),
    repeat,
    (
        read_string(UserInput),
        number_string(UserInputNumber, UserInput),
        between(1, MovesAmount, UserInputNumber),
        MoveIndex is UserInputNumber - 1,
        nth0(MoveIndex, PossibleMoves, Direction-(_:_)), !;
        writeln("Invalid input. Please pick one of the moves above."),
        fail
    ).

read_string(String):-
    current_input(Input),
    read_line_to_codes(Input, Codes),
    string_codes(String, Codes).

press_to_continue :-
    writeln("Press any key to let the computer play..."),
    get_single_char(_).
